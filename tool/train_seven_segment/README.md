# Seven-segment digit classifier

Trains `assets/models/seven_segment_digit.tflite`, the per-digit classifier that
reads meter LCDs. Kept in the repo so the model's provenance is auditable and it
can be retrained rather than being an opaque binary.

## Why a custom model

General text recognition cannot read seven-segment displays. A benchmark of ~25
pretrained scene-text recognisers on real seven-segment images put the best —
PARSeq — at **56.97%** word accuracy, with PaddleOCR's best at 34.34% and CRNN at
18.79% ([ITM Web of Conferences 63, 01007, 2024](https://doi.org/10.1051/itmconf/20246301007),
CC BY 4.0). ML Kit reading `228235` from a display showing `02282385` in this app
is that structural limit, not a bug.

Nor was there a permissively-licensed model to borrow. The seven-segment niche is
hobby projects that never had a licence added, and the one popular candidate —
jomjol's `dig-class11` — had MIT **deliberately removed** in Dec 2021, with its
author stating in [issue #4041](https://github.com/jomjol/AI-on-the-edge-device/issues/4041)
that he cannot license the training images because their provenance is unverifiable.
Training our own was the only path that is both accurate and legally clean.

## Model contract

Mirrored exactly in `lib/core/utils/seven_segment_cnn.dart`. Changing one without
the other silently produces wrong digits.

| | |
|---|---|
| input | `float32 [1, 28, 28, 1]` greyscale, scaled `x/255` into `[0,1]` |
| output | `float32 [1, 10]` softmax over `'0'`–`'9'` |
| quantization | dynamic-range weights, **float32 I/O** |

Float32 I/O is deliberate. Full int8 would be smaller, but it forces the caller to
apply quantization scale and zero-point by hand, and a mistake there yields
plausible-looking wrong digits — precisely the failure this model exists to remove.

## Data sources and licences

| Source | Licence | Contribution |
|---|---|---|
| [MiXaiLL76/7SEG_OCR](https://huggingface.co/datasets/MiXaiLL76/7SEG_OCR) | MIT | 3,333 synthetic strips → 1,924 accepted digit crops |
| [Zenodo 17855380](https://doi.org/10.5281/zenodo.17855380) | CC BY 4.0 (verified via Zenodo API) | real LED photographs, per-digit |

Worth knowing about the HuggingFace set: its labels are noisy — an image showing
`-3820` is labelled `.-3820`, with a decimal point nowhere on the panel — and the
renders include non-digit chrome beside the display. `extract_digits.py` therefore
accepts only **self-validating** extractions: the ink-run count must equal the
expected glyph count and run widths must be consistent. That rejects ~42% of
strips, which is the point; force-splitting the rest would produce confidently
mislabelled cells, worse for a classifier than less data.

`sample_digits.png` is a contact sheet of the accepted crops, one row per digit —
check it after any data change, since a labelling error is invisible in the
accuracy number but obvious here.

## Results

Held-out test: **99.47%** (n=188). Validation: **99.65%** (n=283).

**These figures are on synthetic data.** Real-photo accuracy is a separate
question and is not established by them. Two known gaps:

- The training crops are LED-style (bright on dark); target meters are LCD (dark
  on pale green). Polarity inversion augmentation is meant to cover this, but it is
  untested on hardware.
- Perspective skew, glare and motion blur from a handheld phone are only
  *approximated* by augmentation.

An earlier architecture using `GlobalAveragePooling2D` scored **20%** — it
collapsed to predicting only `1` and `2`. Average pooling is translation-invariant,
and for seven-segment digits the position of a lit bar *is* the class: `6` and `9`
differ only in which vertical segment is on. `Flatten` preserves that. Do not
reintroduce global pooling here.

## Running it

TensorFlow does not support Python 3.14, so use 3.12:

```bash
mkdir -p ~/.meterpulse-train && cd ~/.meterpulse-train
python3.12 -m venv venv
./venv/bin/pip install "tensorflow==2.21.0" pillow numpy pyarrow pandas

curl -L -o hf_7seg.parquet \
  https://huggingface.co/datasets/MiXaiLL76/7SEG_OCR/resolve/main/data/train-00000-of-00001.parquet

cp <repo>/tool/train_seven_segment/*.py .
./venv/bin/python inspect_data.py     # look at the data before trusting it
./venv/bin/python extract_digits.py   # -> digits.npz + contact_sheet.png
./venv/bin/python train_cnn.py        # -> seven_segment_digit.tflite

cp seven_segment_digit.tflite <repo>/assets/models/
```

## Improving accuracy

In rough order of expected value:

1. **Fine-tune on your own captures.** The app already stores the LCD crop for
   every reading, and each manual correction is a ground-truth label on the exact
   meters being read. A few hundred of those should beat any public dataset.
2. **Add [seeed-studio-dbk14/digital-meter-electricity](https://universe.roboflow.com/seeed-studio-dbk14/digital-meter-electricity)**
   — MIT, 543 real images with per-digit boxes (~3,258 real cells). Needs a
   Roboflow account to export.
3. **Add [fyp-zodww/seven-segment-display-ocr](https://universe.roboflow.com/fyp-zodww/seven-segment-display-ocr-lguqw)**
   — CC BY 4.0, 1,199 real images, 12 classes including `.` and `kwh`. Also needs
   an account. Attribution required.

"""Turn seven-segment datasets into labelled per-digit crops.

Produces a single npz of (images, labels) that train_cnn.py consumes.

Two sources, deliberately different in character:

  HF MiXaiLL76/7SEG_OCR (MIT) — 3,333 SYNTHETIC strips labelled with the whole
  number, so digits must be split out. Synthetic data alone is a known trap on
  this project: the geometric decoder passed every synthetic test and still had
  to be rewritten four times against real photos. It is used here for volume,
  not for realism.

  Zenodo 17855380 (CC BY 4.0) — REAL seven-segment LED photographs. Fewer, but
  they carry the glare, skew and blur that decide whether any of this survives
  contact with a meter.

Splitting strategy is adaptive rather than assumed. Uniform pitch is only a
guess about someone else's renderer, so the column ink profile is measured first:
when the number of ink runs matches the label length, those runs give exact
character bounds. Even division is the fallback, and the script reports how often
each path was taken so the guess is visible instead of silent.
"""

import io
import os
import sys
import zipfile
from collections import Counter

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
CELL_W, CELL_H = 28, 28  # matches the per-digit classifier in the Zenodo paper
DIGITS = "0123456789"


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def _otsu(gray):
    """Otsu threshold on a uint8 array."""
    hist = np.bincount(gray.ravel(), minlength=256).astype(np.float64)
    total = gray.size
    omega = np.cumsum(hist)
    mu = np.cumsum(hist * np.arange(256))
    mu_t = mu[-1]
    denom = omega * (total - omega)
    denom[denom == 0] = 1e-9
    sigma_b = (mu_t * omega - total * mu) ** 2 / denom
    return int(np.argmax(sigma_b))


def _ink_mask(gray):
    """Binary ink mask, polarity chosen so ink is the MINORITY class.

    Segments occupy less area than the panel background on any real display, so
    whichever side of the threshold is rarer is the ink. This makes the extractor
    work unchanged on dark-on-light LCDs and bright-on-dark LEDs.
    """
    t = _otsu(gray)
    dark = gray < t
    return dark if dark.mean() <= 0.5 else ~dark


def _content_box(mask, frac=0.04):
    """Bounding box of substantial ink, ignoring speckle and bezel edges."""
    h, w = mask.shape
    col = mask.sum(axis=0)
    row = mask.sum(axis=1)
    cthr = max(1, int(h * frac))
    rthr = max(1, int(w * frac))
    xs = np.where(col >= cthr)[0]
    ys = np.where(row >= rthr)[0]
    if xs.size == 0 or ys.size == 0:
        return None
    return xs[0], ys[0], xs[-1], ys[-1]


def _ink_runs(mask, x0, x1, y0, y1, frac=0.04):
    """Contiguous inked column runs inside the box — candidate character bounds."""
    sub = mask[y0 : y1 + 1, x0 : x1 + 1]
    h = sub.shape[0]
    col = sub.sum(axis=0)
    on = col >= max(1, int(h * frac))
    runs = []
    start = None
    for i, v in enumerate(on):
        if v and start is None:
            start = i
        elif not v and start is not None:
            runs.append((start + x0, i - 1 + x0))
            start = None
    if start is not None:
        runs.append((start + x0, len(on) - 1 + x0))
    return runs


def _crop_cell(gray, left, right, top, bottom, pad_frac=0.18):
    """Crop one cell and resize to the classifier's input size.

    Padded because a tight crop is what breaks a per-digit classifier: a `1`
    occupies a fraction of its cell's width, so cropping to its ink would rescale
    it into something resembling an `8`'s stroke spacing. Padding preserves the
    digit's true proportions within the cell.
    """
    w = right - left + 1
    h = bottom - top + 1
    px = int(round(w * pad_frac))
    py = int(round(h * pad_frac))
    l = max(0, left - px)
    r = min(gray.shape[1] - 1, right + px)
    t = max(0, top - py)
    b = min(gray.shape[0] - 1, bottom + py)
    if r <= l or b <= t:
        return None
    cell = Image.fromarray(gray[t : b + 1, l : r + 1])
    return np.array(cell.resize((CELL_W, CELL_H), Image.BILINEAR), dtype=np.uint8)


def split_strip(gray, label):
    """Split a strip into (cell, digit) pairs, ACCEPTING ONLY self-validating cases.

    Returns (pairs, reason). An empty list means the strip was rejected.

    Precision over volume, deliberately. Inspecting this dataset turned up two
    hazards: the labels are noisy (an image showing "-3820" is labelled ".-3820",
    with a decimal point that is nowhere on the panel), and the renders include
    non-digit chrome — a solid coloured block beside the display — that any naive
    ink bounding box swallows. Force-splitting through either produces confidently
    mislabelled cells, which is worse for a classifier than having less data.

    So instead of trying to detect chrome and repair labels, the extraction is
    required to agree with itself: pure-digit labels only, and the number of ink
    runs found must equal the number of characters expected. Chrome merges or adds
    runs; a phantom label character breaks the count. Both then fail the check and
    the strip is dropped. Run widths must also be broadly consistent, since a
    solid block reads much wider than a digit.
    """
    if not label or not any(c in DIGITS for c in label):
        return [], "reject:no-digits-in-label"
    if any(c not in DIGITS + ".-" for c in label):
        return [], "reject:unexpected-char"

    mask = _ink_mask(gray)
    box = _content_box(mask)
    if box is None:
        return [], "reject:no-ink"
    x0, y0, x1, y1 = box
    if x1 - x0 < 8 or y1 - y0 < 8:
        return [], "reject:too-small"

    runs = _ink_runs(mask, x0, x1, y0, y1)

    # Which label characters actually occupy a cell? Two readings are plausible
    # and the data does not say which applies to a given image:
    #   without dots — a decimal renders as a tiny dot that merges into a
    #                  neighbour's ink run, or is a phantom in the label entirely
    #                  (an image showing "-3820" is labelled ".-3820")
    #   with dots    — the decimal forms its own run
    # Rather than guess, both are tried and whichever matches the observed run
    # count wins. If neither matches, the strip is rejected. '-' is kept as a
    # cell-occupier throughout because it is always rendered full width, but it
    # yields no training sample since it is not a digit.
    candidates = [
        [c for c in label if c != "."],
        list(label),
    ]
    glyphs = None
    for cand in candidates:
        if len(cand) == len(runs):
            glyphs = cand
            break
    if glyphs is None:
        return [], f"reject:runs{len(runs)}!=glyphs{len(candidates[0])}"
    digits = glyphs

    # 3. Consistent run widths. A chrome block is far wider than a digit, so a
    #    lone outlier means the box is not purely digits. A '1' is legitimately
    #    narrow, hence an asymmetric tolerance.
    widths = [r - l + 1 for l, r in runs]
    med = sorted(widths)[len(widths) // 2]
    if med <= 0:
        return [], "reject:zero-width"
    if any(w > med * 2.2 for w in widths):
        return [], "reject:width-outlier"

    # 4. Cells are cut to the FULL box height, not each run's own extent: digit
    #    height is a fixed property of the panel, and per-run vertical cropping
    #    would rescale a '1' or a '-' differently from an '8'.
    pairs = []
    for (rl, rr), g in zip(runs, digits):
        if g not in DIGITS:
            continue  # '-' and '.' hold a cell but are not classes we train on
        c = _crop_cell(gray, rl, rr, y0, y1)
        if c is None:
            return [], "reject:crop-failed"
        pairs.append((c, g))
    if not pairs:
        return [], "reject:no-digit-cells"
    return pairs, "accept"


# --------------------------------------------------------------------------- #
# sources
# --------------------------------------------------------------------------- #
def from_parquet(path, limit=None):
    import pyarrow.parquet as pq

    print(f"\n--- HF synthetic: {path}")
    cells, labels = [], []
    methods = Counter()
    pf = pq.ParquetFile(path)
    seen = 0
    for batch in pf.iter_batches(batch_size=256, columns=["image", "text"]):
        imgs = batch.column("image").to_pylist()
        texts = batch.column("text").to_pylist()
        for rec, text in zip(imgs, texts):
            if limit and seen >= limit:
                break
            seen += 1
            raw = rec["bytes"] if isinstance(rec, dict) else rec
            try:
                gray = np.array(Image.open(io.BytesIO(raw)).convert("L"))
            except Exception:
                methods["decode-fail"] += 1
                continue
            pairs, method = split_strip(gray, str(text))
            methods[method] += 1
            for c, d in pairs:
                cells.append(c)
                labels.append(DIGITS.index(d))
        if limit and seen >= limit:
            break
    print(f"    strips read : {seen}")
    print(f"    split method: {dict(methods)}")
    print(f"    digit crops : {len(cells)}")
    return cells, labels


def from_zenodo_zip(path):
    """Ingest the Zenodo LED archive.

    Layout is unknown ahead of time, so it is discovered: any image whose path
    contains a lone digit directory component is taken as that class. Whatever
    does not match is counted and reported rather than quietly dropped.
    """
    print(f"\n--- Zenodo real LED: {path}")
    if not os.path.exists(path):
        print("    not present, skipping")
        return [], []
    cells, labels = [], []
    unmatched = Counter()
    try:
        z = zipfile.ZipFile(path)
    except zipfile.BadZipFile:
        print("    archive incomplete or corrupt (still downloading?) — skipping")
        return [], []
    with z:
        names = [
            n
            for n in z.namelist()
            if n.lower().endswith((".png", ".jpg", ".jpeg", ".bmp"))
        ]
        print(f"    image entries: {len(names)}")
        for n in names:
            parts = [p for p in n.split("/") if p]
            cls = None
            for p in parts[:-1]:
                if len(p) == 1 and p in DIGITS:
                    cls = p
            if cls is None:
                stem = os.path.splitext(parts[-1])[0]
                if len(stem) == 1 and stem in DIGITS:
                    cls = stem
            if cls is None:
                unmatched["/".join(parts[:-1])[:60]] += 1
                continue
            try:
                with z.open(n) as f:
                    gray = np.array(Image.open(io.BytesIO(f.read())).convert("L"))
            except Exception:
                continue
            mask = _ink_mask(gray)
            box = _content_box(mask)
            if box is None:
                cell = np.array(
                    Image.fromarray(gray).resize((CELL_W, CELL_H), Image.BILINEAR),
                    dtype=np.uint8,
                )
            else:
                x0, y0, x1, y1 = box
                cell = _crop_cell(gray, x0, x1, y0, y1)
            if cell is not None:
                cells.append(cell)
                labels.append(DIGITS.index(cls))
    print(f"    digit crops  : {len(cells)}")
    if unmatched:
        print("    UNMATCHED paths (top 10) — inspect before trusting coverage:")
        for k, v in unmatched.most_common(10):
            print(f"      {v:6d}  {k}")
    return cells, labels


# --------------------------------------------------------------------------- #
def main():
    hf = os.path.join(HERE, "hf_7seg.parquet")
    zn = os.path.join(HERE, "zenodo_led.zip")

    cells, labels, source = [], [], []
    if os.path.exists(hf):
        c, l = from_parquet(hf)
        cells += c
        labels += l
        source += ["synthetic"] * len(c)
    c, l = from_zenodo_zip(zn)
    cells += c
    labels += l
    source += ["real"] * len(c)

    if not cells:
        print("\nNO DATA EXTRACTED — aborting rather than training on nothing.")
        sys.exit(1)

    X = np.stack(cells).astype(np.uint8)
    y = np.array(labels, dtype=np.int64)
    src = np.array(source)

    print(f"\n{'=' * 70}\nTOTAL: {len(X)} crops  shape={X.shape}")
    print("per-class counts:", dict(sorted(Counter(y.tolist()).items())))
    print("per-source counts:", dict(Counter(src.tolist())))

    out = os.path.join(HERE, "digits.npz")
    np.savez_compressed(out, X=X, y=y, src=src)
    print(f"wrote {out} ({os.path.getsize(out) / 1e6:.1f} MB)")

    # Save a visual contact sheet — cheap insurance against training on garbage.
    grid = Image.new("L", (CELL_W * 20, CELL_H * 10), 255)
    for d in range(10):
        idx = np.where(y == d)[0][:20]
        for j, i in enumerate(idx):
            grid.paste(Image.fromarray(X[i]), (j * CELL_W, d * CELL_H))
    sheet = os.path.join(HERE, "contact_sheet.png")
    grid.save(sheet)
    print(f"wrote {sheet} (rows = digit 0..9)")


if __name__ == "__main__":
    main()

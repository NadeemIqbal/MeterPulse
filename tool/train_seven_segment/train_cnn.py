"""Train a per-digit seven-segment classifier and export it as TFLite.

Contract with the Dart side (lib/core/utils/seven_segment_cnn.dart) — any change
here must be mirrored there:

    input   float32 [1, 28, 28, 1], grayscale, scaled x/255.0 into [0,1]
    output  float32 [1, 10], softmax over digits '0'..'9'

Float32 I/O with dynamic-range weight quantization, deliberately. Full int8 would
be smaller still, but it forces the caller to apply quantization scale and
zero-point by hand, and a silent mistake there produces plausible-looking wrong
digits — the exact failure mode this whole exercise exists to eliminate. The model
is a few hundred KB either way, so the tradeoff is not worth taking.

Augmentation is where the real work happens. The training data is largely
synthetic, and synthetic seven-segment digits have already fooled this project
once. Every transform below corresponds to a way a real phone photo of a meter
differs from a clean render:

    polarity inversion  LED panels are bright-on-dark, the target LCDs are
                        dark-on-light. Without this the model learns the wrong
                        sign and fails completely on real meters.
    brightness/contrast glare and backlight variation
    blur                hand shake and imperfect autofocus
    rotate/shear        the phone is never square to the panel
    noise               sensor noise at the short exposures a bright LCD forces
    erase               specular highlights blanking part of a segment
"""

import os
import sys

import numpy as np
import tensorflow as tf

HERE = os.path.dirname(os.path.abspath(__file__))
CELL = 28
NUM_CLASSES = 10
SEED = 1337

rng = np.random.default_rng(SEED)
tf.random.set_seed(SEED)


# --------------------------------------------------------------------------- #
def load():
    path = os.path.join(HERE, "digits.npz")
    if not os.path.exists(path):
        print("digits.npz missing — run extract_digits.py first")
        sys.exit(1)
    d = np.load(path, allow_pickle=True)
    X, y, src = d["X"], d["y"], d["src"]
    print(f"loaded {len(X)} crops, shape {X.shape}")
    real = int((src == "real").sum())
    print(f"  real: {real}   synthetic: {len(X) - real}")
    if real == 0:
        print(
            "\n  *** WARNING: NO REAL PHOTOGRAPHS IN TRAINING SET ***\n"
            "  The model will be trained on synthetic renders only. Accuracy on\n"
            "  actual meter photos is UNVERIFIED and should be treated as unknown\n"
            "  until tested on hardware.\n"
        )
    return X, y, src


def stratified_split(y, val_frac=0.15, test_frac=0.10):
    """Stratified split so every digit appears in every split."""
    idx_tr, idx_va, idx_te = [], [], []
    for c in range(NUM_CLASSES):
        idx = np.where(y == c)[0]
        rng.shuffle(idx)
        n = len(idx)
        n_te = max(1, int(n * test_frac))
        n_va = max(1, int(n * val_frac))
        idx_te += idx[:n_te].tolist()
        idx_va += idx[n_te : n_te + n_va].tolist()
        idx_tr += idx[n_te + n_va :].tolist()
    return np.array(idx_tr), np.array(idx_va), np.array(idx_te)


# --------------------------------------------------------------------------- #
def augment(img, label):
    """img: float32 [28,28,1] in [0,1]."""
    # Polarity: the single most important transform. Half the batch is inverted
    # so the model cannot rely on ink being dark or bright.
    if tf.random.uniform([]) < 0.5:
        img = 1.0 - img

    img = tf.image.random_brightness(img, 0.35)
    img = tf.image.random_contrast(img, 0.5, 1.8)

    # Small affine jitter via crop-and-resize: cheaper than a full transform and
    # covers the rotation/scale/translation a handheld capture introduces.
    if tf.random.uniform([]) < 0.7:
        pad = 4
        img = tf.image.resize_with_crop_or_pad(img, CELL + pad, CELL + pad)
        img = tf.image.random_crop(img, [CELL, CELL, 1])

    # Blur, approximated by downsample/upsample — no scipy dependency needed.
    if tf.random.uniform([]) < 0.3:
        small = tf.image.resize(img, [CELL // 2, CELL // 2], method="bilinear")
        img = tf.image.resize(small, [CELL, CELL], method="bilinear")

    img = img + tf.random.normal(tf.shape(img), stddev=0.05)

    # Specular highlight: blank a random band, as glare across a segment does.
    if tf.random.uniform([]) < 0.25:
        h = tf.random.uniform([], 3, 8, dtype=tf.int32)
        top = tf.random.uniform([], 0, CELL - h, dtype=tf.int32)
        mask = tf.concat(
            [
                tf.ones([top, CELL, 1]),
                tf.zeros([h, CELL, 1]),
                tf.ones([CELL - top - h, CELL, 1]),
            ],
            axis=0,
        )
        img = img * mask + (1.0 - mask) * tf.random.uniform([])

    return tf.clip_by_value(img, 0.0, 1.0), label


def make_ds(X, y, training, batch=128):
    ds = tf.data.Dataset.from_tensor_slices(
        (X.astype(np.float32)[..., None] / 255.0, y.astype(np.int32))
    )
    if training:
        ds = ds.shuffle(min(len(X), 20000), seed=SEED)
        ds = ds.map(augment, num_parallel_calls=tf.data.AUTOTUNE)
    return ds.batch(batch).prefetch(tf.data.AUTOTUNE)


# --------------------------------------------------------------------------- #
def build_model():
    """Small CNN. Seven-segment glyphs have no intra-class shape variance, so
    capacity is spent on robustness to capture conditions, not on shape modelling.
    Kept deliberately tiny to stay a ~100-400 KB asset."""
    L = tf.keras.layers
    return tf.keras.Sequential(
        [
            L.Input((CELL, CELL, 1)),
            L.Conv2D(32, 3, padding="same", activation="relu"),
            L.BatchNormalization(),
            L.MaxPool2D(),  # 14x14
            L.Conv2D(64, 3, padding="same", activation="relu"),
            L.BatchNormalization(),
            L.MaxPool2D(),  # 7x7
            L.Conv2D(128, 3, padding="same", activation="relu"),
            L.BatchNormalization(),
            # Flatten, NOT GlobalAveragePooling. Global average pooling is
            # translation-invariant, and for seven-segment digits the position of
            # a lit bar IS the class: 6 and 9 differ only in which vertical
            # segment is on, and averaging over space makes them indistinguishable.
            # With GAP here the model collapsed to 20% accuracy, predicting only
            # 1 and 2 — every other digit scored 0%.
            L.Flatten(),
            L.Dropout(0.3),
            L.Dense(128, activation="relu"),
            L.Dense(NUM_CLASSES, activation="softmax"),
        ],
        name="seven_segment_digit",
    )


# --------------------------------------------------------------------------- #
def report(model, X, y, src, idx, title):
    if len(idx) == 0:
        return
    xb = X[idx].astype(np.float32)[..., None] / 255.0
    pred = model.predict(xb, verbose=0).argmax(axis=1)
    truth = y[idx]
    acc = (pred == truth).mean()
    print(f"\n{title}: {acc * 100:.2f}%  (n={len(idx)})")

    print("  per class:", end=" ")
    for c in range(NUM_CLASSES):
        m = truth == c
        if m.sum():
            print(f"{c}:{(pred[m] == c).mean() * 100:.0f}%", end=" ")
    print()

    # Split by provenance — synthetic accuracy is nearly meaningless on its own,
    # and reporting only the blended number would hide that.
    for s in ("real", "synthetic"):
        m = src[idx] == s
        if m.sum():
            print(f"  {s:>9}: {(pred[m] == truth[m]).mean() * 100:.2f}% (n={int(m.sum())})")

    conf = np.zeros((NUM_CLASSES, NUM_CLASSES), dtype=int)
    for t, p in zip(truth, pred):
        conf[t, p] += 1
    worst = []
    for t in range(NUM_CLASSES):
        for p in range(NUM_CLASSES):
            if t != p and conf[t, p]:
                worst.append((conf[t, p], t, p))
    worst.sort(reverse=True)
    if worst:
        print("  top confusions:", ", ".join(f"{t}->{p} x{n}" for n, t, p in worst[:8]))
    return acc


# --------------------------------------------------------------------------- #
def export_tflite(model, X, idx_train):
    """Dynamic-range quantized, float32 I/O — see module docstring."""
    conv = tf.lite.TFLiteConverter.from_keras_model(model)
    conv.optimizations = [tf.lite.Optimize.DEFAULT]
    tfl = conv.convert()
    out = os.path.join(HERE, "seven_segment_digit.tflite")
    with open(out, "wb") as f:
        f.write(tfl)
    print(f"\nwrote {out}  ({len(tfl) / 1024:.0f} KB)")

    # Verify the exported model actually agrees with Keras — a conversion that
    # silently degrades is worse than one that fails.
    interp = tf.lite.Interpreter(model_content=tfl)
    interp.allocate_tensors()
    inp = interp.get_input_details()[0]
    outp = interp.get_output_details()[0]
    print(f"  input : {inp['shape']} {inp['dtype']}")
    print(f"  output: {outp['shape']} {outp['dtype']}")

    check = idx_train[:400]
    agree = 0
    for i in check:
        x = (X[i].astype(np.float32) / 255.0)[None, ..., None]
        interp.set_tensor(inp["index"], x)
        interp.invoke()
        tfl_pred = int(interp.get_tensor(outp["index"]).argmax())
        keras_pred = int(model.predict(x, verbose=0).argmax())
        agree += tfl_pred == keras_pred
    print(f"  tflite/keras agreement on {len(check)} samples: {agree / len(check) * 100:.1f}%")
    return out


def main():
    X, y, src = load()
    itr, iva, ite = stratified_split(y)
    print(f"split: train={len(itr)} val={len(iva)} test={len(ite)}")

    model = build_model()
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    model.summary()

    # Class weights: meter digit frequency is not uniform (leading positions skew
    # low), so without this the rare classes are quietly sacrificed.
    counts = np.bincount(y[itr], minlength=NUM_CLASSES).astype(np.float64)
    counts[counts == 0] = 1
    weights = {c: float(counts.sum() / (NUM_CLASSES * counts[c])) for c in range(NUM_CLASSES)}
    print("class weights:", {k: round(v, 2) for k, v in weights.items()})

    model.fit(
        make_ds(X[itr], y[itr], training=True),
        validation_data=make_ds(X[iva], y[iva], training=False),
        epochs=40,
        class_weight=weights,
        callbacks=[
            tf.keras.callbacks.EarlyStopping(
                monitor="val_accuracy", patience=8, restore_best_weights=True
            ),
            tf.keras.callbacks.ReduceLROnPlateau(
                monitor="val_loss", factor=0.5, patience=4, min_lr=1e-5
            ),
        ],
        verbose=2,
    )

    report(model, X, y, src, iva, "VALIDATION")
    report(model, X, y, src, ite, "HELD-OUT TEST")
    export_tflite(model, X, itr)


if __name__ == "__main__":
    main()

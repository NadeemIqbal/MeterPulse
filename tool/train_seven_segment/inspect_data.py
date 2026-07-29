"""Look at the raw data before building any pipeline around it.

Assuming a dataset's layout has already cost time on this project once (a
synthetic renderer that drew segment bars flush to the cell edge, unlike real
hardware). So: dump real samples, print real shapes, decide afterwards.
"""

import io
import os
import sys
import zipfile

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "inspect")
os.makedirs(OUT, exist_ok=True)


def inspect_parquet(path, n=12):
    import pyarrow.parquet as pq

    print(f"\n{'=' * 70}\nHF PARQUET: {path}\n{'=' * 70}")
    pf = pq.ParquetFile(path)
    print("rows:", pf.metadata.num_rows)
    print("schema:", pf.schema_arrow)

    table = pf.read_row_group(0)
    cols = table.column_names
    print("columns:", cols)

    texts = table.column("text").to_pylist()[:200]
    print("\nsample texts:", texts[:20])
    lens = [len(t) for t in texts]
    print("text length distribution:", {l: lens.count(l) for l in sorted(set(lens))})
    charset = sorted({c for t in texts for c in t})
    print("charset seen:", charset)

    imgs = table.column("image").to_pylist()[:n]
    for i, rec in enumerate(imgs):
        raw = rec["bytes"] if isinstance(rec, dict) else rec
        im = Image.open(io.BytesIO(raw))
        arr = np.array(im.convert("L"))
        name = f"hf_{i:02d}_{texts[i]}.png"
        im.save(os.path.join(OUT, name))
        # Column ink profile tells us whether digits are uniformly pitched and
        # whether the strip is tightly cropped -- that decides how to split it.
        col = arr.mean(axis=0)
        dark = col < (arr.min() + arr.max()) / 2
        runs = []
        start = None
        for x, d in enumerate(dark):
            if d and start is None:
                start = x
            elif not d and start is not None:
                runs.append((start, x - 1))
                start = None
        if start is not None:
            runs.append((start, len(dark) - 1))
        print(
            f"  {name}: size={im.size} mode={im.mode} "
            f"gray[min={arr.min()},max={arr.max()},mean={arr.mean():.0f}] "
            f"dark_col_runs={len(runs)} (text has {len(texts[i])} chars)"
        )


def inspect_zip(path, limit=40):
    print(f"\n{'=' * 70}\nZENODO ZIP: {path}\n{'=' * 70}")
    if not os.path.exists(path):
        print("not downloaded yet")
        return
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        print("entries:", len(names))
        # Directory shape reveals whether crops are pre-split per class.
        tops = {}
        for n in names:
            parts = n.split("/")
            key = "/".join(parts[:2]) if len(parts) > 1 else parts[0]
            tops[key] = tops.get(key, 0) + 1
        print("\ntop-level structure (path prefix -> count):")
        for k, v in sorted(tops.items(), key=lambda kv: -kv[1])[:30]:
            print(f"  {v:7d}  {k}")

        imgs = [n for n in names if n.lower().endswith((".png", ".jpg", ".jpeg", ".bmp"))]
        print(f"\nimage entries: {len(imgs)}")
        for n in imgs[:8]:
            with z.open(n) as f:
                im = Image.open(io.BytesIO(f.read()))
                print(f"  {n}  size={im.size} mode={im.mode}")
        labels = [n for n in names if n.lower().endswith((".txt", ".csv", ".json", ".xml"))]
        print(f"\nlabel-ish entries: {len(labels)}")
        for n in labels[:10]:
            print("  ", n)


if __name__ == "__main__":
    hf = os.path.join(HERE, "hf_7seg.parquet")
    zn = os.path.join(HERE, "zenodo_led.zip")
    if os.path.exists(hf) and "--skip-hf" not in sys.argv:
        try:
            inspect_parquet(hf)
        except Exception as e:  # partial download is expected mid-flight
            print("parquet not readable yet:", e)
    inspect_zip(zn)
    print(f"\nsample images written to {OUT}")

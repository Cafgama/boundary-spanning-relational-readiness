#!/usr/bin/env python3
"""Combine E5 execution slices without changing row contents."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

EXPECTED_K = {4,7,8,9,10,11,13,15}


def main() -> None:
    ap=argparse.ArgumentParser()
    ap.add_argument("--input-dir",required=True,type=Path)
    ap.add_argument("--output",required=True,type=Path)
    ap.add_argument("--replications",required=True,type=int)
    args=ap.parse_args()

    paths=sorted(args.input_dir.glob("e5_k*.csv"))
    if len(paths)!=8:
        raise ValueError(f"Expected 8 E5 slice files, got {len(paths)}")

    rows=[]
    fieldnames=None
    seen_k=set()
    for path in paths:
        with path.open(newline="",encoding="utf-8") as fh:
            reader=csv.DictReader(fh)
            if fieldnames is None:
                fieldnames=reader.fieldnames
            elif reader.fieldnames != fieldnames:
                raise ValueError(f"Header mismatch in {path}")
            part=list(reader)
        ks={int(r["k"]) for r in part}
        if len(ks)!=1:
            raise ValueError(f"Slice {path} contains multiple k values: {ks}")
        k=next(iter(ks)); seen_k.add(k)
        expected=3*4*2*args.replications
        if len(part)!=expected:
            raise ValueError(f"Slice k={k}: expected {expected} rows, got {len(part)}")
        rows.extend(part)

    if seen_k != EXPECTED_K:
        raise ValueError(f"Unexpected E5 k coverage: {sorted(seen_k)}")

    rows.sort(key=lambda r:(float(r["Omega"]),int(r["replication"]),int(r["k"]),float(r["ell_s"]),r["policy"]))
    expected_total=8*3*4*2*args.replications
    if len(rows)!=expected_total:
        raise ValueError(f"Expected {expected_total} total rows, got {len(rows)}")

    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open("w",newline="",encoding="utf-8") as fh:
        writer=csv.DictWriter(fh,fieldnames=fieldnames)
        writer.writeheader(); writer.writerows(rows)
    print(f"Wrote combined E5 raw file: {args.output} ({len(rows)} rows)")


if __name__=="__main__":
    main()

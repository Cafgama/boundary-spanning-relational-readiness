#!/usr/bin/env python3
"""Summarize E2 learning-focus screening data using only the standard library."""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from collections import defaultdict
from pathlib import Path
from typing import Dict, List


def quantile(values: List[float], q: float) -> float:
    xs = sorted(values)
    if not xs:
        raise ValueError("quantile requires data")
    if len(xs) == 1:
        return xs[0]
    pos = q * (len(xs) - 1)
    lo = int(math.floor(pos))
    hi = int(math.ceil(pos))
    if lo == hi:
        return xs[lo]
    w = pos - lo
    return xs[lo] * (1 - w) + xs[hi] * w


def load_groups(path: Path):
    groups: Dict[float, List[dict]] = defaultdict(list)
    with path.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        required = {
            "replication", "h", "H", "S2", "initial_increment", "T_mean_cross",
            "TA", "TB", "T", "T_tilde", "delta", "Theta", "ell",
        }
        missing = required.difference(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Missing required columns: {sorted(missing)}")
        for row in reader:
            groups[float(row["h"])].append(row)
    if not groups:
        raise ValueError("No E2 rows found")
    return groups


def summarize(h: float, rows: List[dict]) -> dict:
    deltas = [int(r["delta"]) for r in rows]
    t_tilde = [float(r["T_tilde"]) for r in rows]
    observed_t = [float(r["T"]) for r in rows if int(r["delta"]) == 1]
    ta = [float(r["TA"]) for r in rows if r["TA"].lower() != "nan"]
    tb = [float(r["TB"]) for r in rows if r["TB"].lower() != "nan"]

    if not observed_t:
        raise ValueError(f"No observed system crossings for h={h}")

    mean_t = statistics.fmean(observed_t)
    sd_t = statistics.stdev(observed_t) if len(observed_t) > 1 else 0.0

    def single(name: str) -> float:
        vals = {float(r[name]) for r in rows}
        if len(vals) != 1:
            raise ValueError(f"{name} varies within h={h}: {vals}")
        return vals.pop()

    t_mean_cross = single("T_mean_cross")

    return {
        "h": h,
        "H": single("H"),
        "S2": single("S2"),
        "Theta": single("Theta"),
        "ell": single("ell"),
        "R": len(rows),
        "event_fraction": statistics.fmean(deltas),
        "mean_T": mean_t,
        "sd_T": sd_t,
        "mcse_T": sd_t / math.sqrt(len(observed_t)),
        "q05_T": quantile(observed_t, 0.05),
        "q50_T": quantile(observed_t, 0.50),
        "q90_T": quantile(observed_t, 0.90),
        "q95_T": quantile(observed_t, 0.95),
        "mean_TA": statistics.fmean(ta),
        "mean_TB": statistics.fmean(tb),
        "mean_T_tilde": statistics.fmean(t_tilde),
        "initial_increment": single("initial_increment"),
        "T_mean_cross": t_mean_cross,
        "mean_T_minus_mean_cross": mean_t - t_mean_cross,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    groups = load_groups(args.input)
    rows = [summarize(h, group) for h, group in sorted(groups.items())]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0].keys())
    with args.output.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote E2 summary to {args.output}")


if __name__ == "__main__":
    main()

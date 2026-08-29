#!/usr/bin/env python3
"""Summarize E1 admission-convergence screening data.

Uses only Python's standard library so the summary step is lightweight and
reproducible. Figures remain a separate concern.
"""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from collections import defaultdict
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


GroupKey = Tuple[str, int, float]


def quantile(values: List[float], q: float) -> float:
    if not values:
        raise ValueError("quantile requires at least one value")
    if not 0 <= q <= 1:
        raise ValueError("q must lie in [0,1]")

    xs = sorted(values)
    if len(xs) == 1:
        return xs[0]

    pos = q * (len(xs) - 1)
    lo = int(math.floor(pos))
    hi = int(math.ceil(pos))
    if lo == hi:
        return xs[lo]
    weight = pos - lo
    return xs[lo] * (1 - weight) + xs[hi] * weight


def read_groups(path: Path):
    groups: Dict[GroupKey, List[dict]] = defaultdict(list)

    with path.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        required = {
            "condition",
            "replication",
            "seed",
            "C",
            "D",
            "Omega",
            "H",
            "Lambda",
            "chi",
            "n_served",
            "n_blocked",
            "blocked_fraction",
            "fluid_blocked_fraction",
        }
        missing = required.difference(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Missing required columns: {sorted(missing)}")

        for row in reader:
            key = (row["condition"], int(row["C"]), float(row["Omega"]))
            groups[key].append(row)

    if not groups:
        raise ValueError("Input file contains no data rows")

    return groups


def summarize_group(key: GroupKey, rows: List[dict]) -> dict:
    condition, C, omega = key
    blocked = [float(r["blocked_fraction"]) for r in rows]
    fluid_values = [float(r["fluid_blocked_fraction"]) for r in rows]
    H_values = [float(r["H"]) for r in rows]
    lambda_values = [float(r["Lambda"]) for r in rows]
    chi_values = [float(r["chi"]) for r in rows]
    D_values = [int(r["D"]) for r in rows]

    if len(set(D_values)) != 1:
        raise ValueError(f"D varies within group {key}")

    mean_blocked = statistics.fmean(blocked)
    if len(blocked) > 1:
        sd_blocked = statistics.stdev(blocked)
        mcse = sd_blocked / math.sqrt(len(blocked))
    else:
        sd_blocked = 0.0
        mcse = 0.0

    fluid = statistics.fmean(fluid_values)

    return {
        "condition": condition,
        "C": C,
        "D": D_values[0],
        "Omega": omega,
        "H": statistics.fmean(H_values),
        "Lambda": statistics.fmean(lambda_values),
        "chi": statistics.fmean(chi_values),
        "R": len(blocked),
        "mean_blocked_fraction": mean_blocked,
        "sd_blocked_fraction": sd_blocked,
        "mcse_blocked_fraction": mcse,
        "q05_blocked_fraction": quantile(blocked, 0.05),
        "q50_blocked_fraction": quantile(blocked, 0.50),
        "q95_blocked_fraction": quantile(blocked, 0.95),
        "fluid_blocked_fraction": fluid,
        "mean_minus_fluid": mean_blocked - fluid,
    }


def write_summary(groups, output_path: Path) -> None:
    summaries = [summarize_group(k, v) for k, v in groups.items()]
    summaries.sort(key=lambda r: (r["condition"], r["C"], r["Omega"]))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "condition",
        "C",
        "D",
        "Omega",
        "H",
        "Lambda",
        "chi",
        "R",
        "mean_blocked_fraction",
        "sd_blocked_fraction",
        "mcse_blocked_fraction",
        "q05_blocked_fraction",
        "q50_blocked_fraction",
        "q95_blocked_fraction",
        "fluid_blocked_fraction",
        "mean_minus_fluid",
    ]

    with output_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(summaries)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    groups = read_groups(args.input)
    write_summary(groups, args.output)
    print(f"Wrote E1 summary to {args.output}")


if __name__ == "__main__":
    main()

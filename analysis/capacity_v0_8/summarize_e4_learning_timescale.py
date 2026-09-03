#!/usr/bin/env python3
"""Summarize preregistered E4 learning-timescale stochastic screening."""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Tuple

GroupKey = Tuple[str, float, float, float]


def quantile(values: List[float], q: float) -> float:
    if not values:
        return math.nan
    xs = sorted(values)
    if len(xs) == 1:
        return xs[0]
    pos = q * (len(xs) - 1)
    lo = int(math.floor(pos))
    hi = int(math.ceil(pos))
    if lo == hi:
        return xs[lo]
    w = pos - lo
    return xs[lo] * (1-w) + xs[hi] * w


def finite(values: List[float]) -> List[float]:
    return [x for x in values if math.isfinite(x)]


def mean_or_nan(values: List[float]) -> float:
    return statistics.fmean(values) if values else math.nan


def constant(rows: List[dict], field: str) -> float:
    vals = [float(r[field]) for r in rows]
    if max(vals)-min(vals) > 1e-10:
        raise ValueError(f"{field} varies within one E4 cell")
    return statistics.fmean(vals)


def read_groups(path: Path):
    groups: Dict[GroupKey,List[dict]] = defaultdict(list)
    with path.open(newline="",encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        required = {
            "policy","replication","demand_seed","k","h","H","alpha","primary_oos",
            "C","D","Omega","Lambda","chi","t0_real","t0_integer","Psi",
            "T_fluid","fluid_delay_vs_t0","T_capacity","T_capacity_tilde","delta_capacity",
            "T_free","T_free_tilde","delta_free","DeltaT","n_attempted","n_served",
            "n_blocked","blocked_fraction","any_block","first_block_attempt",
            "n_windows_started","Wmin_final",
        }
        missing = required.difference(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Missing required columns: {sorted(missing)}")
        for row in reader:
            key = (row["policy"],float(row["alpha"]),float(row["h"]),float(row["Omega"]))
            groups[key].append(row)
    if not groups:
        raise ValueError("Input file contains no E4 data rows")
    return groups


def summarize_group(key: GroupKey, rows: List[dict]) -> dict:
    policy,alpha,h,omega = key
    delta_cap = [int(r["delta_capacity"]) for r in rows]
    delta_free = [int(r["delta_free"]) for r in rows]
    t_tilde = [float(r["T_capacity_tilde"]) for r in rows]
    observed_t = [float(r["T_capacity"]) for r in rows if int(r["delta_capacity"]) == 1]
    observed_free = [float(r["T_free"]) for r in rows if int(r["delta_free"]) == 1]
    delays = finite([float(r["DeltaT"]) for r in rows])
    blocked_fraction = [float(r["blocked_fraction"]) for r in rows]
    any_block = [int(r["any_block"]) for r in rows]
    first_block = finite([float(r["first_block_attempt"]) for r in rows])
    n_blocked = [int(r["n_blocked"]) for r in rows]
    n_windows = [int(r["n_windows_started"]) for r in rows]

    if any(x < -1e-12 for x in delays):
        raise ValueError(f"Negative paired delay found in E4 cell {key}")

    t_fluid = constant(rows,"T_fluid")
    fluid_delay = constant(rows,"fluid_delay_vs_t0")
    mean_t = mean_or_nan(observed_t)
    mean_delay = mean_or_nan(delays)

    return {
        "policy":policy,
        "alpha":alpha,
        "primary_oos":int(round(constant(rows,"primary_oos"))),
        "k":int(round(constant(rows,"k"))),
        "h":h,
        "H":constant(rows,"H"),
        "C":int(round(constant(rows,"C"))),
        "D":int(round(constant(rows,"D"))),
        "Omega":omega,
        "Lambda":constant(rows,"Lambda"),
        "chi":constant(rows,"chi"),
        "t0_real":constant(rows,"t0_real"),
        "t0_integer":int(round(constant(rows,"t0_integer"))),
        "Psi":constant(rows,"Psi"),
        "T_fluid":t_fluid,
        "fluid_delay_vs_t0":fluid_delay,
        "R":len(rows),
        "event_fraction_capacity":statistics.fmean(delta_cap),
        "event_fraction_free":statistics.fmean(delta_free),
        "rmst_capacity":statistics.fmean(t_tilde),
        "mean_T_observed":mean_t,
        "median_T_observed":quantile(observed_t,0.50),
        "mean_T_free_observed":mean_or_nan(observed_free),
        "n_delay_estimable":len(delays),
        "mean_DeltaT":mean_delay,
        "median_DeltaT":quantile(delays,0.50),
        "q90_DeltaT":quantile(delays,0.90),
        "q95_DeltaT":quantile(delays,0.95),
        "max_DeltaT":max(delays) if delays else math.nan,
        "mean_blocked_fraction":statistics.fmean(blocked_fraction),
        "prob_any_block":statistics.fmean(any_block),
        "mean_n_blocked":statistics.fmean(n_blocked),
        "mean_first_block_attempt_conditional":mean_or_nan(first_block),
        "mean_windows_started":statistics.fmean(n_windows),
        "T_error_observed_minus_fluid":mean_t-t_fluid if math.isfinite(mean_t) else math.nan,
        "delay_error_observed_minus_fluid":mean_delay-fluid_delay if math.isfinite(mean_delay) else math.nan,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--input",required=True,type=Path)
    ap.add_argument("--output",required=True,type=Path)
    args = ap.parse_args()

    groups = read_groups(args.input)
    rows = [summarize_group(k,v) for k,v in groups.items()]
    rows.sort(key=lambda r:(r["policy"],r["alpha"],r["Omega"],r["h"]))
    if len(rows) != 168:
        raise ValueError(f"Expected 168 E4 cells, got {len(rows)}")

    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open("w",newline="",encoding="utf-8") as fh:
        writer = csv.DictWriter(fh,fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote E4 summary to {args.output}")


if __name__ == "__main__":
    main()

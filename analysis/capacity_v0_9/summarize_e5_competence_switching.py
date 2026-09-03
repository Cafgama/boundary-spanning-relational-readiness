#!/usr/bin/env python3
"""Summarize preregistered E5 competence-switching screening."""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Tuple

GroupKey = Tuple[str, float, int, float]


def quantile(values: List[float], q: float) -> float:
    if not values:
        return math.nan
    xs = sorted(values)
    if len(xs) == 1:
        return xs[0]
    pos = q * (len(xs)-1)
    lo = int(math.floor(pos)); hi = int(math.ceil(pos))
    if lo == hi:
        return xs[lo]
    w = pos-lo
    return xs[lo]*(1-w)+xs[hi]*w


def finite(values: List[float]) -> List[float]:
    return [x for x in values if math.isfinite(x)]


def constant(rows: List[dict], field: str) -> float:
    vals=[float(r[field]) for r in rows]
    if max(vals)-min(vals) > 1e-9:
        raise ValueError(f"{field} varies within E5 cell")
    return statistics.fmean(vals)


def read_groups(path: Path):
    groups: Dict[GroupKey,List[dict]] = defaultdict(list)
    with path.open(newline="",encoding="utf-8") as fh:
        reader=csv.DictReader(fh)
        required={
            "policy","replication","k","h","H","ell_o","ell_s","C","D","Omega",
            "Lambda","chi","regime","ell_star","T_theory_concentrated","T_theory_diffuse",
            "theory_architecture_advantage","T_capacity","T_capacity_tilde","delta_capacity",
            "T_free","T_free_tilde","delta_free","capacity_penalty_tilde","n_blocked",
            "blocked_fraction","first_block_attempt","n_windows_started","T_diffuse_capacity",
            "T_diffuse_capacity_tilde","delta_diffuse_capacity","T_diffuse_free",
            "T_diffuse_free_tilde","delta_diffuse_free","architecture_advantage_tilde",
        }
        missing=required.difference(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Missing E5 columns: {sorted(missing)}")
        for row in reader:
            key=(row["policy"],float(row["Omega"]),int(row["k"]),float(row["ell_s"]))
            groups[key].append(row)
    if not groups:
        raise ValueError("No E5 rows")
    return groups


def summarize(key: GroupKey, rows: List[dict]) -> dict:
    policy,omega,k,ell_s=key
    regime={r["regime"] for r in rows}
    if len(regime)!=1:
        raise ValueError("regime varies within E5 cell")
    regime=next(iter(regime))

    cap_tilde=[float(r["T_capacity_tilde"]) for r in rows]
    free_tilde=[float(r["T_free_tilde"]) for r in rows]
    diff_tilde=[float(r["T_diffuse_capacity_tilde"]) for r in rows]
    cap_delta=[int(r["delta_capacity"]) for r in rows]
    free_delta=[int(r["delta_free"]) for r in rows]
    diff_delta=[int(r["delta_diffuse_capacity"]) for r in rows]
    cap_obs=[float(r["T_capacity"]) for r in rows if int(r["delta_capacity"])==1]
    penalties=[float(r["capacity_penalty_tilde"]) for r in rows]
    arch=[float(r["architecture_advantage_tilde"]) for r in rows]
    blocked=[float(r["blocked_fraction"]) for r in rows]
    first_block=finite([float(r["first_block_attempt"]) for r in rows])

    if any(x < -1e-12 for x in penalties):
        raise ValueError(f"Negative capacity penalty in cell {key}")

    ell_star=constant(rows,"ell_star") if regime != "unrescuable" else math.nan
    return {
        "policy":policy,
        "Omega":omega,
        "k":k,
        "h":constant(rows,"h"),
        "H":constant(rows,"H"),
        "ell_o":constant(rows,"ell_o"),
        "ell_s":ell_s,
        "C":int(round(constant(rows,"C"))),
        "D":int(round(constant(rows,"D"))),
        "Lambda":constant(rows,"Lambda"),
        "chi":constant(rows,"chi"),
        "regime":regime,
        "ell_star":ell_star,
        "T_theory_concentrated":constant(rows,"T_theory_concentrated"),
        "T_theory_diffuse":constant(rows,"T_theory_diffuse"),
        "theory_architecture_advantage":constant(rows,"theory_architecture_advantage"),
        "R":len(rows),
        "event_fraction_capacity":statistics.fmean(cap_delta),
        "event_fraction_free":statistics.fmean(free_delta),
        "event_fraction_diffuse":statistics.fmean(diff_delta),
        "rmst_capacity":statistics.fmean(cap_tilde),
        "rmst_free":statistics.fmean(free_tilde),
        "rmst_diffuse_capacity":statistics.fmean(diff_tilde),
        "rmst_capacity_penalty":statistics.fmean(cap_tilde)-statistics.fmean(free_tilde),
        "rmst_architecture_advantage":statistics.fmean(cap_tilde)-statistics.fmean(diff_tilde),
        "mean_row_capacity_penalty":statistics.fmean(penalties),
        "mean_row_architecture_advantage":statistics.fmean(arch),
        "mean_T_observed":statistics.fmean(cap_obs) if cap_obs else math.nan,
        "median_T_observed":quantile(cap_obs,0.50),
        "q90_T_observed":quantile(cap_obs,0.90),
        "q95_T_observed":quantile(cap_obs,0.95),
        "mean_blocked_fraction":statistics.fmean(blocked),
        "prob_any_block":statistics.fmean([1 if float(r["n_blocked"])>0 else 0 for r in rows]),
        "mean_first_block_attempt_conditional":statistics.fmean(first_block) if first_block else math.nan,
        "mean_windows_started":statistics.fmean([float(r["n_windows_started"]) for r in rows]),
    }


def main() -> None:
    ap=argparse.ArgumentParser()
    ap.add_argument("--input",required=True,type=Path)
    ap.add_argument("--output",required=True,type=Path)
    args=ap.parse_args()
    groups=read_groups(args.input)
    rows=[summarize(k,v) for k,v in groups.items()]
    rows.sort(key=lambda r:(r["policy"],r["Omega"],r["k"],r["ell_s"]))
    if len(rows)!=192:
        raise ValueError(f"Expected 192 E5 cells, got {len(rows)}")
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open("w",newline="",encoding="utf-8") as fh:
        writer=csv.DictWriter(fh,fieldnames=list(rows[0].keys()))
        writer.writeheader(); writer.writerows(rows)
    print(f"Wrote E5 summary to {args.output}")


if __name__=="__main__":
    main()

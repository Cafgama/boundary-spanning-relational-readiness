#!/usr/bin/env python3
"""Frozen E6 summarizer for transient capacity-shock tail risk.

Primary delay variable is the signed paired restricted first-passage delay
`shock_delay_tilde` relative to the same trajectory at gamma=1.

Quantiles use the empirical nearest-rank definition:
    q_p = x_(ceil(p*n))
for sorted observations x_(1) <= ... <= x_(n).
ES95 is the arithmetic mean of observations greater than or equal to the
nearest-rank q95 threshold.
"""

import argparse
import csv
import math
from collections import defaultdict
from statistics import mean


def f(row, key):
    return float(row[key])


def nearest_rank(values, p):
    xs = sorted(values)
    if not xs:
        return math.nan
    rank = max(1, math.ceil(p * len(xs)))
    return xs[rank - 1]


def tail_summary(values):
    q50 = nearest_rank(values, 0.50)
    q90 = nearest_rank(values, 0.90)
    q95 = nearest_rank(values, 0.95)
    q99 = nearest_rank(values, 0.99)
    tail = [x for x in values if x >= q95]
    return {
        "mean": mean(values),
        "median": q50,
        "q90": q90,
        "q95": q95,
        "q99": q99,
        "es95": mean(tail),
    }


def read_raw(path):
    groups = defaultdict(list)
    diffuse = {}
    with open(path, newline="") as fh:
        rows = list(csv.DictReader(fh))

    for row in rows:
        key = (row["policy"], int(row["k"]), float(row["ell_s"]), float(row["gamma"]))
        groups[key].append(row)

        dkey = (int(row["replication"]), float(row["gamma"]))
        dvals = (
            f(row, "diffuse_T_shock_tilde"),
            f(row, "diffuse_T_noshock_tilde"),
            f(row, "diffuse_shock_delay_tilde"),
            f(row, "diffuse_shock_blocked_fraction"),
            int(float(row["diffuse_delta_shock"])),
        )
        if dkey in diffuse:
            assert diffuse[dkey] == dvals, (dkey, diffuse[dkey], dvals)
        else:
            diffuse[dkey] = dvals

    return rows, groups, diffuse


def diffuse_by_gamma(diffuse):
    out = {}
    gammas = sorted({g for _, g in diffuse})
    for gamma in gammas:
        vals = [v for (rep, g), v in diffuse.items() if g == gamma]
        delays = [v[2] for v in vals]
        tvals = [v[0] for v in vals]
        blocked = [v[3] for v in vals]
        events = [v[4] for v in vals]
        S = tail_summary(delays)
        out[gamma] = {
            "R": len(vals),
            "event_fraction": mean(events),
            "mean_T_tilde": mean(tvals),
            "mean_delay": S["mean"],
            "median_delay": S["median"],
            "q90_delay": S["q90"],
            "q95_delay": S["q95"],
            "q99_delay": S["q99"],
            "es95_delay": S["es95"],
            "prob_negative_delay": mean([d < 0 for d in delays]),
            "mean_shock_blocked_fraction": mean(blocked),
        }
    return out


def summarize_group(rows, diffuse_summary):
    first = rows[0]
    delays = [f(r, "shock_delay_tilde") for r in rows]
    tvals = [f(r, "T_shock_tilde") for r in rows]
    events = [int(float(r["delta_shock"])) for r in rows]
    blocked = [f(r, "shock_blocked_fraction") for r in rows]
    prodA = [f(r, "n_productive_A_shock") for r in rows]
    prodB = [f(r, "n_productive_B_shock") for r in rows]
    arch = [f(r, "architecture_advantage_tilde") for r in rows]
    D = int(float(first["D"]))

    S = tail_summary(delays)
    gamma = f(first, "gamma")
    DS = diffuse_summary[gamma]

    return {
        "policy": first["policy"],
        "k": int(first["k"]),
        "h": f(first, "h"),
        "H": f(first, "H"),
        "ell_o": f(first, "ell_o"),
        "ell_s": f(first, "ell_s"),
        "C": int(float(first["C"])),
        "D": D,
        "Omega": f(first, "Omega"),
        "Lambda": f(first, "Lambda"),
        "chi": f(first, "chi"),
        "gamma": gamma,
        "gamma_real": f(first, "gamma_real"),
        "C_shock": int(float(first["C_shock"])),
        "chi_shock_fluid": f(first, "chi_shock_fluid"),
        "R": len(rows),
        "event_fraction": mean(events),
        "mean_T_tilde": mean(tvals),
        "mean_shock_delay": S["mean"],
        "median_shock_delay": S["median"],
        "q90_shock_delay": S["q90"],
        "q95_shock_delay": S["q95"],
        "q99_shock_delay": S["q99"],
        "ES95_shock_delay": S["es95"],
        "prob_delay_ge_one_window": mean([d >= D for d in delays]),
        "prob_negative_delay": mean([d < 0 for d in delays]),
        "mean_shock_blocked_fraction": mean(blocked),
        "prob_any_shock_block": mean([b > 0 for b in blocked]),
        "mean_productive_A_shock": mean(prodA),
        "mean_productive_B_shock": mean(prodB),
        "mean_architecture_advantage_tilde": mean(arch),
        "diffuse_mean_shock_delay": DS["mean_delay"],
        "diffuse_q95_shock_delay": DS["q95_delay"],
        "diffuse_ES95_shock_delay": DS["es95_delay"],
        "diffuse_prob_negative_delay": DS["prob_negative_delay"],
        "q95_resilience_contrast": S["q95"] - DS["q95_delay"],
        "ES95_resilience_contrast": S["es95"] - DS["es95_delay"],
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    raw, groups, diffuse = read_raw(args.input)
    dsummary = diffuse_by_gamma(diffuse)

    summaries = []
    for key in sorted(groups, key=lambda x: (x[0], x[1], x[2], -x[3])):
        summaries.append(summarize_group(groups[key], dsummary))

    assert len(summaries) == len(groups)
    assert all(s["gamma_real"] == s["gamma"] for s in summaries)

    fieldnames = list(summaries[0].keys())
    with open(args.output, "w", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(summaries)

    print(f"Wrote E6 summary: {args.output} ({len(summaries)} cells from {len(raw)} rows)")


if __name__ == "__main__":
    main()

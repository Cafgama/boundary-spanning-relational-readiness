#!/usr/bin/env python3
"""Frozen post-summary evaluator for E6 hypotheses.

This script does not fit thresholds. It classifies preregistered speed/resilience
trade-offs using gamma=1 mean architecture advantage and shock q95/ES95
contrasts against the diffuse benchmark.
"""

import argparse
import csv
from collections import defaultdict
from statistics import mean


def load_rows(path):
    with open(path, newline="") as fh:
        rows = list(csv.DictReader(fh))
    numeric = {
        "k","ell_s","gamma","mean_architecture_advantage_tilde",
        "mean_shock_delay","q95_shock_delay","ES95_shock_delay",
        "q95_resilience_contrast","ES95_resilience_contrast",
        "prob_negative_delay","chi","chi_shock_fluid"
    }
    for r in rows:
        for k in numeric:
            r[k] = float(r[k])
        r["k"] = int(r["k"])
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--summary", required=True)
    ap.add_argument("--cells-output", required=True)
    ap.add_argument("--metrics-output", required=True)
    args = ap.parse_args()

    rows = load_rows(args.summary)
    assert len(rows) == 120

    baseline = {}
    for r in rows:
        if r["gamma"] == 1.0:
            key = (r["policy"], r["k"], r["ell_s"])
            baseline[key] = r["mean_architecture_advantage_tilde"]
    assert len(baseline) == 24

    evaluated = []
    for r in rows:
        key = (r["policy"], r["k"], r["ell_s"])
        b = baseline[key]
        faster = int(b < 0)
        tail_q95_worse = int(r["q95_resilience_contrast"] > 0)
        tail_es_worse = int(r["ES95_resilience_contrast"] > 0)
        e = dict(r)
        e["baseline_mean_architecture_advantage"] = b
        e["baseline_faster_than_diffuse"] = faster
        e["tail_worse_than_diffuse_q95"] = tail_q95_worse
        e["tail_worse_than_diffuse_ES95"] = tail_es_worse
        e["speed_resilience_tradeoff_q95"] = int(r["gamma"] < 1 and faster and tail_q95_worse)
        e["speed_resilience_tradeoff_ES95"] = int(r["gamma"] < 1 and faster and tail_es_worse)
        evaluated.append(e)

    fieldnames = list(evaluated[0].keys())
    with open(args.cells_output, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(evaluated)

    metrics = []
    def add(scope, metric, value):
        metrics.append({"scope": scope, "metric": metric, "value": value})

    shock = [r for r in evaluated if r["gamma"] < 1]
    add("all_shock_cells", "n_cells", len(shock))
    add("all_shock_cells", "fraction_speed_resilience_tradeoff_q95",
        mean([r["speed_resilience_tradeoff_q95"] for r in shock]))
    add("all_shock_cells", "fraction_speed_resilience_tradeoff_ES95",
        mean([r["speed_resilience_tradeoff_ES95"] for r in shock]))
    add("all_shock_cells", "fraction_with_any_negative_delay_probability",
        mean([r["prob_negative_delay"] > 0 for r in shock]))
    add("all_shock_cells", "max_probability_negative_delay",
        max(r["prob_negative_delay"] for r in shock))

    # H6.2: pair uniform and matched at identical k, ell_s, gamma.
    lookup = {(r["policy"],r["k"],r["ell_s"],r["gamma"]): r for r in evaluated}
    mismatch_pairs = []
    for k in [4,7,9,15]:
        for ell in [0.7,0.9,1.0]:
            for gamma in [0.8,0.6,0.5,0.4]:
                u = lookup[("uniform",k,ell,gamma)]
                m = lookup[("matched",k,ell,gamma)]
                mismatch_pairs.append((u,m))
    add("uniform_vs_matched", "n_paired_cells", len(mismatch_pairs))
    add("uniform_vs_matched", "fraction_uniform_q95_delay_greater",
        mean([u["q95_shock_delay"] > m["q95_shock_delay"] for u,m in mismatch_pairs]))
    add("uniform_vs_matched", "fraction_uniform_ES95_delay_greater",
        mean([u["ES95_shock_delay"] > m["ES95_shock_delay"] for u,m in mismatch_pairs]))

    # H6.3: compare ell_s=1 with ell_s=.7 at fixed architecture and shock.
    competence_pairs = []
    for policy in ["matched","uniform"]:
        for k in [4,7,9,15]:
            for gamma in [0.8,0.6,0.5,0.4]:
                low = lookup[(policy,k,0.7,gamma)]
                high = lookup[(policy,k,1.0,gamma)]
                competence_pairs.append((low,high))
    add("competence_1_vs_0.7", "n_paired_cells", len(competence_pairs))
    add("competence_1_vs_0.7", "fraction_mean_delay_lower_at_ell1",
        mean([hi["mean_shock_delay"] < lo["mean_shock_delay"] for lo,hi in competence_pairs]))
    add("competence_1_vs_0.7", "fraction_q95_delay_lower_at_ell1",
        mean([hi["q95_shock_delay"] < lo["q95_shock_delay"] for lo,hi in competence_pairs]))
    add("competence_1_vs_0.7", "fraction_ES95_delay_lower_at_ell1",
        mean([hi["ES95_shock_delay"] < lo["ES95_shock_delay"] for lo,hi in competence_pairs]))

    with open(args.metrics_output, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["scope","metric","value"])
        w.writeheader()
        w.writerows(metrics)

    print(f"Wrote E6 evaluated cells: {args.cells_output} ({len(evaluated)} cells)")
    print(f"Wrote E6 frozen metrics: {args.metrics_output} ({len(metrics)} metrics)")


if __name__ == "__main__":
    main()

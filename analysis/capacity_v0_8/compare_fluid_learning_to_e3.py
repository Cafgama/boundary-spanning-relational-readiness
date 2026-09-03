#!/usr/bin/env python3
"""Compare post-E3 Model v0.8 deterministic predictions with E3 processed means."""

import argparse
import csv
import math
from pathlib import Path


def pearson(xs, ys):
    if len(xs) < 2:
        return float('nan')
    mx = sum(xs) / len(xs)
    my = sum(ys) / len(ys)
    num = sum((x-mx)*(y-my) for x,y in zip(xs,ys))
    denx = math.sqrt(sum((x-mx)**2 for x in xs))
    deny = math.sqrt(sum((y-my)**2 for y in ys))
    return num/(denx*deny) if denx > 0 and deny > 0 else float('nan')


def mae(xs):
    return sum(abs(x) for x in xs)/len(xs) if xs else float('nan')


def rmse(xs):
    return math.sqrt(sum(x*x for x in xs)/len(xs)) if xs else float('nan')


def load_predictions(path):
    out = {}
    with open(path, newline='') as f:
        for row in csv.DictReader(f):
            key = (row['policy'], int(row['k']), round(float(row['Omega']), 12))
            out[key] = row
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--summary', required=True)
    ap.add_argument('--predictions', required=True)
    ap.add_argument('--comparison-output', required=True)
    ap.add_argument('--metrics-output', required=True)
    args = ap.parse_args()

    predictions = load_predictions(args.predictions)
    rows = []
    with open(args.summary, newline='') as f:
        for obs in csv.DictReader(f):
            h = float(obs['h'])
            k = int(round(15*h))
            key = (obs['policy'], k, round(float(obs['Omega']), 12))
            if key not in predictions:
                raise RuntimeError(f'Missing prediction for {key}')
            pred = predictions[key]
            t_obs = float(obs['mean_T_observed'])
            t_pred = float(pred['T_fluid'])
            delay_obs = float(obs['mean_DeltaT'])
            delay_pred = float(pred['fluid_delay_vs_t0'])
            rows.append({
                'policy': obs['policy'],
                'k': k,
                'h': h,
                'Omega': float(obs['Omega']),
                'chi': float(obs['chi']),
                'Psi': float(obs['Psi']),
                'mean_T_observed': t_obs,
                'T_fluid': t_pred,
                'T_error_observed_minus_fluid': t_obs-t_pred,
                'mean_DeltaT_observed': delay_obs,
                'fluid_delay_vs_t0': delay_pred,
                'delay_error_observed_minus_fluid': delay_obs-delay_pred,
                'prob_any_block': float(obs['prob_any_block']),
                'mean_blocked_fraction': float(obs['mean_blocked_fraction']),
            })

    if len(rows) != 224:
        raise RuntimeError(f'Expected 224 comparison rows, got {len(rows)}')

    out_path = Path(args.comparison_output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    scopes = {
        'all': rows,
        'uniform': [r for r in rows if r['policy'] == 'uniform'],
        'uniform_excluding_k14': [r for r in rows if r['policy'] == 'uniform' and r['k'] != 14],
        'matched': [r for r in rows if r['policy'] == 'matched'],
    }

    metrics = []
    for scope, rr in scopes.items():
        terr = [r['T_error_observed_minus_fluid'] for r in rr]
        derr = [r['delay_error_observed_minus_fluid'] for r in rr]
        metrics.extend([
            (scope, 'n_cells', len(rr)),
            (scope, 'pearson_T', pearson([r['mean_T_observed'] for r in rr], [r['T_fluid'] for r in rr])),
            (scope, 'pearson_delay', pearson([r['mean_DeltaT_observed'] for r in rr], [r['fluid_delay_vs_t0'] for r in rr])),
            (scope, 'MAE_T', mae(terr)),
            (scope, 'RMSE_T', rmse(terr)),
            (scope, 'MAE_delay', mae(derr)),
            (scope, 'RMSE_delay', rmse(derr)),
        ])

    metrics_path = Path(args.metrics_output)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    with open(metrics_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['scope','metric','value'])
        for scope, metric, value in metrics:
            writer.writerow([scope, metric, f'{value:.15g}' if isinstance(value, float) else value])

    print(f'Wrote comparison to {out_path}')
    print(f'Wrote metrics to {metrics_path}')


if __name__ == '__main__':
    main()

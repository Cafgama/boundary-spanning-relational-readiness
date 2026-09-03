#!/usr/bin/env python3
"""Evaluate preregistered E4 out-of-sample predictive performance.

Uses only cell-level summaries. Primary OOS subset:
  policy == 'uniform'
  primary_oos == 1  (alpha in {0.06, 0.10, 0.12})
Metrics are reported for first-passage time and paired delay:
Pearson correlation, MAE, and RMSE.
"""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from pathlib import Path
from typing import List, Tuple


def pearson(x: List[float], y: List[float]) -> float:
    if len(x) != len(y) or len(x) < 2:
        return math.nan
    mx = statistics.fmean(x)
    my = statistics.fmean(y)
    sx = sum((a-mx)**2 for a in x)
    sy = sum((b-my)**2 for b in y)
    if sx <= 0 or sy <= 0:
        return math.nan
    return sum((a-mx)*(b-my) for a,b in zip(x,y)) / math.sqrt(sx*sy)


def mae(x: List[float], y: List[float]) -> float:
    return statistics.fmean(abs(a-b) for a,b in zip(x,y))


def rmse(x: List[float], y: List[float]) -> float:
    return math.sqrt(statistics.fmean((a-b)**2 for a,b in zip(x,y)))


def metric_rows(scope: str, rows: List[dict]) -> List[Tuple[str,str,float]]:
    obs_t = [float(r['mean_T_observed']) for r in rows]
    pred_t = [float(r['T_fluid']) for r in rows]
    obs_d = [float(r['mean_DeltaT']) for r in rows]
    pred_d = [float(r['fluid_delay_vs_t0']) for r in rows]
    return [
        (scope,'n_cells',float(len(rows))),
        (scope,'pearson_T',pearson(pred_t,obs_t)),
        (scope,'MAE_T',mae(pred_t,obs_t)),
        (scope,'RMSE_T',rmse(pred_t,obs_t)),
        (scope,'pearson_delay',pearson(pred_d,obs_d)),
        (scope,'MAE_delay',mae(pred_d,obs_d)),
        (scope,'RMSE_delay',rmse(pred_d,obs_d)),
    ]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument('--summary',required=True,type=Path)
    ap.add_argument('--output',required=True,type=Path)
    args = ap.parse_args()

    with args.summary.open(newline='',encoding='utf-8') as fh:
        rows = list(csv.DictReader(fh))
    if len(rows) != 168:
        raise ValueError(f'Expected 168 E4 summary cells, got {len(rows)}')

    primary_uniform = [r for r in rows if r['policy']=='uniform' and int(r['primary_oos'])==1]
    if len(primary_uniform) != 63:
        raise ValueError(f'Expected 63 primary uniform OOS cells, got {len(primary_uniform)}')

    out = metric_rows('primary_uniform_oos',primary_uniform)
    for alpha in (0.06,0.10,0.12):
        rr = [r for r in primary_uniform if abs(float(r['alpha'])-alpha)<1e-12]
        if len(rr) != 21:
            raise ValueError(f'Expected 21 cells for alpha={alpha}, got {len(rr)}')
        out.extend(metric_rows(f'primary_uniform_alpha_{alpha:.2f}',rr))

    matched_oos = [r for r in rows if r['policy']=='matched' and int(r['primary_oos'])==1]
    if len(matched_oos) != 63:
        raise ValueError(f'Expected 63 matched OOS cells, got {len(matched_oos)}')
    residuals = [float(r['mean_DeltaT'])-float(r['fluid_delay_vs_t0']) for r in matched_oos]
    out.extend([
        ('matched_oos_residual','n_cells',float(len(matched_oos))),
        ('matched_oos_residual','mean_delay_residual',statistics.fmean(residuals)),
        ('matched_oos_residual','MAE_delay_residual',statistics.fmean(abs(x) for x in residuals)),
        ('matched_oos_residual','RMSE_delay_residual',math.sqrt(statistics.fmean(x*x for x in residuals))),
    ])

    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open('w',newline='',encoding='utf-8') as fh:
        w = csv.writer(fh)
        w.writerow(['scope','metric','value'])
        for scope,metric,value in out:
            w.writerow([scope,metric,value])
    print(f'Wrote E4 OOS metrics to {args.output}')


if __name__ == '__main__':
    main()

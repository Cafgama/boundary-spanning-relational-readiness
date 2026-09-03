#!/usr/bin/env python3
"""Evaluate E5 stochastic results against frozen deterministic switching predictions.

No stochastic threshold is fitted. Predictions come directly from each summary
row's preregistered deterministic architecture advantage and regime/ell_star.
"""

from __future__ import annotations

import argparse
import csv
import math
import statistics
from collections import defaultdict
from pathlib import Path


def pearson(x,y):
    if len(x)<2:
        return math.nan
    mx=statistics.fmean(x); my=statistics.fmean(y)
    sx=sum((a-mx)**2 for a in x); sy=sum((b-my)**2 for b in y)
    if sx<=0 or sy<=0:
        return math.nan
    return sum((a-mx)*(b-my) for a,b in zip(x,y))/math.sqrt(sx*sy)


def sign(x,tol=1e-12):
    if x < -tol: return -1
    if x > tol: return 1
    return 0


def metrics(rows):
    theory=[float(r['theory_architecture_advantage']) for r in rows]
    obs=[float(r['rmst_architecture_advantage']) for r in rows]
    err=[o-t for o,t in zip(obs,theory)]
    sign_match=[sign(o)==sign(t) for o,t in zip(obs,theory)]
    return {
        'n_cells':len(rows),
        'pearson_architecture_advantage':pearson(theory,obs),
        'MAE_architecture_advantage':statistics.fmean(abs(e) for e in err),
        'RMSE_architecture_advantage':math.sqrt(statistics.fmean(e*e for e in err)),
        'sign_agreement_fraction':statistics.fmean(sign_match),
    }


def write_long_metric_rows(out_rows,scope,m):
    for metric,value in m.items():
        out_rows.append({'scope':scope,'metric':metric,'value':value})


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--summary',required=True,type=Path)
    ap.add_argument('--metrics-output',required=True,type=Path)
    ap.add_argument('--cell-output',required=True,type=Path)
    args=ap.parse_args()

    with args.summary.open(newline='',encoding='utf-8') as fh:
        rows=list(csv.DictReader(fh))
    if len(rows)!=192:
        raise ValueError(f'Expected 192 E5 summary cells, got {len(rows)}')

    cell_rows=[]
    for r in rows:
        theory=float(r['theory_architecture_advantage'])
        obs=float(r['rmst_architecture_advantage'])
        cell_rows.append({
            'policy':r['policy'],'Omega':r['Omega'],'k':r['k'],'h':r['h'],
            'ell_s':r['ell_s'],'regime':r['regime'],'ell_star':r['ell_star'],
            'theory_architecture_advantage':theory,
            'rmst_architecture_advantage':obs,
            'prediction_favors_concentration':int(theory<=0),
            'observed_favors_concentration':int(obs<=0),
            'sign_match':int(sign(theory)==sign(obs)),
            'error_observed_minus_theory':obs-theory,
        })

    metric_rows=[]
    write_long_metric_rows(metric_rows,'all_cells',metrics(rows))
    write_long_metric_rows(metric_rows,'uniform_all',metrics([r for r in rows if r['policy']=='uniform']))
    write_long_metric_rows(metric_rows,'matched_all',metrics([r for r in rows if r['policy']=='matched']))

    for reg in ('structural_win','competence_rescuable','unrescuable'):
        rr=[r for r in rows if r['policy']=='uniform' and r['regime']==reg]
        if rr:
            write_long_metric_rows(metric_rows,f'uniform_{reg}',metrics(rr))

    # Strong H5.3 check: every targeted uniform cell labeled unrescuable is
    # evaluated specifically at ell_s=1, where deterministic theory says even
    # perfect specialist competence cannot beat the diffuse benchmark.
    unr=[r for r in rows if r['policy']=='uniform' and r['regime']=='unrescuable' and abs(float(r['ell_s'])-1)<1e-12]
    if not unr:
        raise ValueError('No targeted unrescuable ell_s=1 cells found')
    n_unr_favor=sum(float(r['rmst_architecture_advantage'])<=0 for r in unr)
    metric_rows.append({'scope':'uniform_unrescuable_at_ell1','metric':'n_cells','value':len(unr)})
    metric_rows.append({'scope':'uniform_unrescuable_at_ell1','metric':'fraction_still_slower_than_diffuse','value':statistics.fmean(float(r['rmst_architecture_advantage'])>0 for r in unr)})
    metric_rows.append({'scope':'uniform_unrescuable_at_ell1','metric':'n_stochastic_reversals_favoring_concentration','value':n_unr_favor})

    # For rescuable cells, compare the coarse grid switch with the frozen
    # continuous ell_star. We do not estimate a new root. The observed coarse
    # switch is the first preregistered ell level with RMST advantage <= 0.
    grouped=defaultdict(list)
    for r in rows:
        if r['policy']=='uniform' and r['regime']=='competence_rescuable':
            grouped[(r['Omega'],r['k'])].append(r)
    switch_dist=[]; switch_hit=[]
    for key,rr in grouped.items():
        rr=sorted(rr,key=lambda r:float(r['ell_s']))
        star=float(rr[0]['ell_star'])
        predicted_level=next((float(r['ell_s']) for r in rr if float(r['ell_s'])+1e-12>=star),math.nan)
        observed_level=next((float(r['ell_s']) for r in rr if float(r['rmst_architecture_advantage'])<=0),math.nan)
        if math.isfinite(observed_level) and math.isfinite(predicted_level):
            switch_dist.append(abs(observed_level-predicted_level))
            switch_hit.append(observed_level==predicted_level)
    metric_rows.append({'scope':'uniform_rescuable_switch_grid','metric':'n_regime_cells','value':len(grouped)})
    metric_rows.append({'scope':'uniform_rescuable_switch_grid','metric':'fraction_exact_coarse_switch_level','value':statistics.fmean(switch_hit) if switch_hit else math.nan})
    metric_rows.append({'scope':'uniform_rescuable_switch_grid','metric':'mean_absolute_grid_switch_error','value':statistics.fmean(switch_dist) if switch_dist else math.nan})

    args.cell_output.parent.mkdir(parents=True,exist_ok=True)
    with args.cell_output.open('w',newline='',encoding='utf-8') as fh:
        writer=csv.DictWriter(fh,fieldnames=list(cell_rows[0].keys()))
        writer.writeheader(); writer.writerows(cell_rows)
    with args.metrics_output.open('w',newline='',encoding='utf-8') as fh:
        writer=csv.DictWriter(fh,fieldnames=['scope','metric','value'])
        writer.writeheader(); writer.writerows(metric_rows)
    print(f'Wrote E5 preregistered evaluation metrics to {args.metrics_output}')


if __name__=='__main__':
    main()

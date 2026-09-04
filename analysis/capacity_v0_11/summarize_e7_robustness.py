#!/usr/bin/env python3
import argparse
import numpy as np
import pandas as pd

GROUP = ['panel','pairing','policy','n','C','D','Omega','h','H','Theta','K']

def q(x,p):
    return float(np.quantile(np.asarray(x,dtype=float),p,method='higher'))

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--input',required=True)
    ap.add_argument('--output',required=True)
    args=ap.parse_args()

    df=pd.read_csv(args.input)
    rows=[]
    for key,g in df.groupby(GROUP,sort=True,dropna=False):
        r=dict(zip(GROUP,key))
        t=g['T_tilde'].astype(float)
        r.update({
            'R':len(g),
            'event_fraction':float(g['delta'].mean()),
            'mean_T_tilde':float(t.mean()),
            'median_T_tilde':float(t.median()),
            'q90_T_tilde':q(t,.90),
            'q95_T_tilde':q(t,.95),
            'mean_blocked_fraction':float(g['blocked_fraction'].mean()),
            'prob_any_block':float((g['n_blocked']>0).mean()),
        })
        rows.append(r)
    out=pd.DataFrame(rows)
    out.to_csv(args.output,index=False)
    print(f'Wrote E7 summary: {args.output} ({len(out)} cells)')

if __name__=='__main__':
    main()

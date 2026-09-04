#!/usr/bin/env python3
import argparse
import math
import numpy as np
import pandas as pd

KEY=['panel','pairing','policy','n','C','D','Omega','h','Theta']

def sign_tol(x,tol=1e-9):
    if x>tol: return 1
    if x<-tol: return -1
    return 0

def corr(x,y):
    x=np.asarray(x,dtype=float); y=np.asarray(y,dtype=float)
    if len(x)<2 or np.std(x)==0 or np.std(y)==0: return float('nan')
    return float(np.corrcoef(x,y)[0,1])

def add_metric(rows,scope,metric,value):
    rows.append({'scope':scope,'metric':metric,'value':value})

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--summary',required=True)
    ap.add_argument('--predictions',required=True)
    ap.add_argument('--cells-output',required=True)
    ap.add_argument('--metrics-output',required=True)
    args=ap.parse_args()

    s=pd.read_csv(args.summary)
    p=pd.read_csv(args.predictions)
    for c in ['n','C','D']:
        s[c]=s[c].astype(int); p[c]=p[c].astype(int)
    for c in ['Omega','h','Theta']:
        s[c]=s[c].astype(float).round(12); p[c]=p[c].astype(float).round(12)

    e=s.merge(p[KEY+['T_free_theory','T_theory','delay_theory','first_exhaustion_theory',
                       'exact_T_expected','exact_delay_expected','exact_identity_note']],
              on=KEY,how='left',validate='one_to_one')
    assert e['T_theory'].notna().all(), 'Missing frozen theory prediction for an E7 cell.'
    e['T_error']=e['mean_T_tilde']-e['T_theory']
    e.to_csv(args.cells_output,index=False)

    metrics=[]
    add_metric(metrics,'all_cells','n_cells',len(e))
    add_metric(metrics,'all_cells','pearson_T',corr(e['T_theory'],e['mean_T_tilde']))
    add_metric(metrics,'all_cells','MAE_T',float(np.mean(np.abs(e['T_error']))))
    add_metric(metrics,'all_cells','RMSE_T',float(np.sqrt(np.mean(e['T_error']**2))))

    # Matched/uniform architecture penalties.
    pair_keys=['panel','pairing','n','C','D','Omega','h','Theta']
    w=e.pivot(index=pair_keys,columns='policy',values=['mean_T_tilde','T_theory']).reset_index()
    w.columns=['_'.join([str(z) for z in c if str(z)!='']).rstrip('_') if isinstance(c,tuple) else c for c in w.columns]
    w['penalty_obs']=w['mean_T_tilde_uniform']-w['mean_T_tilde_matched']
    w['penalty_theory']=w['T_theory_uniform']-w['T_theory_matched']
    w['sign_match']=[sign_tol(a)==sign_tol(b) for a,b in zip(w['penalty_obs'],w['penalty_theory'])]
    inter=w[(w['h']>1e-12)&(w['h']<1-1e-12)]
    add_metric(metrics,'architecture_penalty_intermediate','n_pairs',len(inter))
    add_metric(metrics,'architecture_penalty_intermediate','sign_agreement_fraction',float(inter['sign_match'].mean()))
    add_metric(metrics,'architecture_penalty_intermediate','pearson_penalty',corr(inter['penalty_theory'],inter['penalty_obs']))
    add_metric(metrics,'architecture_penalty_intermediate','MAE_penalty',float(np.mean(np.abs(inter['penalty_obs']-inter['penalty_theory']))))

    # Panel A reentrance: zero endpoints and positive intermediate mean penalty.
    A=w[w['panel']=='A']
    re=[]
    for _,g in A.groupby(['n','Omega']):
        e0=g[np.isclose(g['h'],0)]['penalty_obs']
        e1=g[np.isclose(g['h'],1)]['penalty_obs']
        mid=g[(g['h']>0)&(g['h']<1)]['penalty_obs']
        re.append((len(e0)==1 and len(e1)==1 and abs(float(e0.iloc[0]))<1e-12 and
                   abs(float(e1.iloc[0]))<1e-12 and float(mid.max())>0))
    add_metric(metrics,'panel_A_scaling','n_groups',len(re))
    add_metric(metrics,'panel_A_scaling','fraction_reentrant_groups',float(np.mean(re)))

    # Exact endpoint identities across B/C and all exact-T rows.
    ex=e[e['exact_T_expected'].notna()].copy()
    ex['exact_abs_error']=np.abs(ex['mean_T_tilde']-ex['exact_T_expected'])
    add_metric(metrics,'exact_identities','n_cells',len(ex))
    add_metric(metrics,'exact_identities','max_abs_error_mean_T',float(ex['exact_abs_error'].max()) if len(ex) else float('nan'))
    add_metric(metrics,'exact_identities','fraction_exact',float((ex['exact_abs_error']<1e-12).mean()) if len(ex) else float('nan'))

    # Panel D reentrance within each pairing/Omega.
    D=w[w['panel']=='D']
    reD=[]
    for _,g in D.groupby(['pairing','Omega']):
        e0=g[np.isclose(g['h'],0)]['penalty_obs']
        e1=g[np.isclose(g['h'],1)]['penalty_obs']
        mid=g[(g['h']>0)&(g['h']<1)]['penalty_obs']
        reD.append((len(e0)==1 and len(e1)==1 and abs(float(e0.iloc[0]))<1e-12 and
                    abs(float(e1.iloc[0]))<1e-12 and float(mid.max())>0))
    add_metric(metrics,'panel_D_pairing','n_groups',len(reD))
    add_metric(metrics,'panel_D_pairing','fraction_reentrant_groups',float(np.mean(reD)))

    # Product versus assortative collateral-blocking direction at intermediate h.
    dp=D[(D['h']>0)&(D['h']<1)].pivot(index=['n','C','D','Omega','h','Theta'],columns='pairing',values='penalty_obs').reset_index()
    if {'product','assortative'}.issubset(dp.columns):
        add_metric(metrics,'panel_D_pairing','n_intermediate_paired_states',len(dp))
        add_metric(metrics,'panel_D_pairing','fraction_product_penalty_greater',float((dp['product']>dp['assortative']).mean()))
        add_metric(metrics,'panel_D_pairing','mean_product_minus_assortative_penalty',float((dp['product']-dp['assortative']).mean()))

    # Panel-specific reduced-theory metrics.
    for panel in ['A','B','C','D']:
        g=e[e['panel']==panel]
        add_metric(metrics,f'panel_{panel}','n_cells',len(g))
        add_metric(metrics,f'panel_{panel}','pearson_T',corr(g['T_theory'],g['mean_T_tilde']))
        add_metric(metrics,f'panel_{panel}','MAE_T',float(np.mean(np.abs(g['T_error']))))

    pd.DataFrame(metrics).to_csv(args.metrics_output,index=False)
    print(f'Wrote E7 evaluated cells: {args.cells_output} ({len(e)} cells)')
    print(f'Wrote E7 metrics: {args.metrics_output} ({len(metrics)} rows)')

if __name__=='__main__':
    main()

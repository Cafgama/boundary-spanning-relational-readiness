# Step 3 — Balanced single-responsibility BS algorithm

This document locks the boundary-spanning network-generation algorithm for the rerun branch `rerun/balanced-survival-bootstrap`.

## Purpose

The old BS generator allowed any cross-boundary tie that involved at least one boundary spanner. That meant a selected tie could connect:

- a university-side boundary spanner to a non-spanner industry actor;
- a non-spanner university actor to an industry-side boundary spanner;
- a university-side boundary spanner to an industry-side boundary spanner.

The rerun design removes this ambiguity. In the new design, every BS tie has **exactly one** boundary-spanner endpoint. The boundary-spanning role is therefore assigned to one side of the tie, not both.

## Locked algorithm

For architecture `boundary_spanning`:

1. Select `b` university-side boundary spanners uniformly without replacement.
2. Select `b` industry-side boundary spanners uniformly without replacement.
3. Define non-spanner university actors as `U_nonBS`.
4. Define non-spanner industry actors as `I_nonBS`.
5. Split the cross-boundary tie budget `k` into side responsibilities:
   - `k_U = ceil(k / 2)` ties assigned to university-side boundary spanners;
   - `k_I = k - k_U` ties assigned to industry-side boundary spanners.
6. If `k` is even, this gives exactly `k/2` ties assigned to each side.
7. If `k` is odd, the two side-responsibility counts differ by one.
8. Distribute `k_U` as evenly as possible across the `b` university-side spanners.
9. Distribute `k_I` as evenly as possible across the `b` industry-side spanners.
10. For each university-side spanner, sample its assigned number of partners from `I_nonBS` without replacement.
11. For each industry-side spanner, sample its assigned number of partners from `U_nonBS` without replacement.
12. Create the selected cross-boundary ties and assign `edge_type = 3`.
13. Store workload diagnostics in the graph object.

## Invariants

A valid rerun-v2 BS network must satisfy:

- exactly `k` cross-boundary ties;
- every BS cross-boundary tie has `edge_type = 3`;
- every BS cross-boundary tie has exactly one boundary-spanner endpoint;
- the opposite endpoint is always a non-boundary-spanner actor;
- if `k` is even, exactly `k/2` ties are assigned to university-side spanners and `k/2` to industry-side spanners;
- within each side, assigned workloads differ by at most one;
- total assigned workload equals `k`;
- no duplicate cross-boundary pairs are selected.

## Failure conditions

The generator must fail early if:

- `b >= nU` or `b >= nI`, because then one side has no non-spanner opposite endpoints;
- `k_U > b * (nI - b)`;
- `k_I > b * (nU - b)`;
- `k` exceeds the exact-one-spanner candidate set.

## Interpretation

This algorithm operationalizes the managerial assumption that boundary-spanning responsibility is assigned to identifiable actors, while the opposite endpoint remains a domain actor with whom the spanner performs translation work. It also separates capability from capacity: translation capability enters through `pi_BS`, while capacity and overload enter through the realized distribution of assigned cross-boundary workload.

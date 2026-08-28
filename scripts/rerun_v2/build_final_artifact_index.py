#!/usr/bin/env python3
"""Build the rerun_v2 final manuscript artifact index.

This script does not run simulations and does not recompute statistics. It checks
for the expected manuscript-facing CSVs and figure files produced by the rerun_v2
pipeline and writes a compact Markdown index to docs/final_artifact_index.md.

Usage
-----
python scripts/rerun_v2/build_final_artifact_index.py
python scripts/rerun_v2/build_final_artifact_index.py --strict
python scripts/rerun_v2/build_final_artifact_index.py --repo-root C:/path/to/repo
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable, List


@dataclass(frozen=True)
class Artifact:
    section: str
    label: str
    role: str
    relative_path: str
    required: bool = True


def repo_root_from_script() -> Path:
    return Path(__file__).resolve().parents[2]


def expected_artifacts() -> List[Artifact]:
    """Return the expected final artifact inventory.

    The list separates inferential evidence blocks from the mini-heatmap design
    map. The mini heatmap is included as a figure-facing synthesis, while the
    main inferential blocks remain final core, translation grid, workload grid,
    selection-rule robustness, and threshold robustness.
    """

    artifacts: List[Artifact] = []

    artifacts.extend([
        Artifact("Master handovers", "Master computational handover", "Writing-track source of truth", "docs/manuscript_results_handover.md"),
        Artifact("Master handovers", "Final core handover", "Mechanism decomposition source", "docs/final_core_results_handover.md"),
        Artifact("Master handovers", "Translation-grid handover", "Translation mechanism source", "docs/translation_grid_results_handover.md"),
        Artifact("Master handovers", "Workload-grid handover", "Role-capacity mechanism source", "docs/workload_grid_results_handover.md"),
        Artifact("Master handovers", "Mini-heatmap handover", "Design-map synthesis source", "docs/mini_heatmap_results_handover.md"),
        Artifact("Master handovers", "Selection-rule handover", "Actor-capacity robustness source", "docs/selection_rule_results_handover.md"),
        Artifact("Master handovers", "Threshold-robustness handover", "Readiness-threshold robustness source", "docs/threshold_robustness_results_handover.md"),
    ])

    artifacts.extend([
        Artifact("Final core tables", "Final core condition estimands", "Table/figure data", "results/processed/rerun_v2/final_core/final_core_condition_estimands.csv"),
        Artifact("Final core tables", "Final core contrasts", "Table/figure data", "results/processed/rerun_v2/final_core/final_core_contrasts.csv"),
        Artifact("Final core figure data", "Final core condition estimands", "Figure-generation data", "results/figure_data/rerun_v2/final_core/final_core_condition_estimands.csv"),
        Artifact("Final core figure data", "Final core contrasts", "Figure-generation data", "results/figure_data/rerun_v2/final_core/final_core_contrasts.csv"),
    ])

    artifacts.extend([
        Artifact("Translation-grid tables", "Translation-grid condition estimands", "Table/figure data", "results/processed/rerun_v2/translation_grid/translation_grid_condition_estimands.csv"),
        Artifact("Translation-grid tables", "Translation-grid contrasts", "Table/figure data", "results/processed/rerun_v2/translation_grid/translation_grid_contrasts.csv"),
        Artifact("Translation-grid figure data", "Translation-grid condition estimands", "Figure-generation data", "results/figure_data/rerun_v2/translation_grid/translation_grid_condition_estimands.csv"),
        Artifact("Translation-grid figure data", "Translation-grid contrasts", "Figure-generation data", "results/figure_data/rerun_v2/translation_grid/translation_grid_contrasts.csv"),
    ])

    artifacts.extend([
        Artifact("Workload-grid tables", "Workload-grid condition estimands", "Table/figure data", "results/processed/rerun_v2/workload_grid/workload_grid_condition_estimands.csv"),
        Artifact("Workload-grid tables", "Workload-grid contrasts", "Table/figure data", "results/processed/rerun_v2/workload_grid/workload_grid_contrasts.csv"),
        Artifact("Workload-grid figure data", "Workload-grid condition estimands", "Figure-generation data", "results/figure_data/rerun_v2/workload_grid/workload_grid_condition_estimands.csv"),
        Artifact("Workload-grid figure data", "Workload-grid contrasts", "Figure-generation data", "results/figure_data/rerun_v2/workload_grid/workload_grid_contrasts.csv"),
    ])

    artifacts.extend([
        Artifact("Mini heatmap tables", "Mini heatmap condition estimates", "Table/figure data", "results/processed/rerun_v2/mini_heatmap/mini_heatmap_condition_estimates.csv"),
        Artifact("Mini heatmap tables", "Mini heatmap RMST matrix", "Primary heatmap data", "results/processed/rerun_v2/mini_heatmap/mini_heatmap_matrix_RMST.csv"),
        Artifact("Mini heatmap tables", "Mini heatmap T95 matrix", "Secondary heatmap data", "results/processed/rerun_v2/mini_heatmap/mini_heatmap_matrix_T95.csv"),
        Artifact("Mini heatmap tables", "Mini heatmap readiness matrix", "Secondary heatmap data", "results/processed/rerun_v2/mini_heatmap/mini_heatmap_matrix_readiness_probability.csv"),
        Artifact("Mini heatmap figure data", "Mini heatmap condition estimates", "Figure-generation data", "results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_condition_estimates.csv"),
        Artifact("Mini heatmap figure data", "Mini heatmap RMST matrix", "Primary figure-generation data", "results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_RMST.csv"),
        Artifact("Mini heatmap figure data", "Mini heatmap T95 matrix", "Secondary figure-generation data", "results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_T95.csv"),
        Artifact("Mini heatmap figure data", "Mini heatmap readiness matrix", "Secondary figure-generation data", "results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_readiness_probability.csv"),
        Artifact("Mini heatmap figure files", "Mini heatmap PNG", "Manuscript review image", "figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.png"),
        Artifact("Mini heatmap figure files", "Mini heatmap PDF", "Submission-quality vector figure", "figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.pdf"),
        Artifact("Mini heatmap figure files", "Mini heatmap caption", "Draft caption text", "figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap_caption.txt"),
    ])

    artifacts.extend([
        Artifact("Selection-rule robustness tables", "Selection-rule condition estimands", "Table/figure data", "results/processed/rerun_v2/selection_rule_robustness/selection_rule_condition_estimands.csv"),
        Artifact("Selection-rule robustness tables", "Selection-rule contrasts", "Table/figure data", "results/processed/rerun_v2/selection_rule_robustness/selection_rule_contrasts.csv"),
        Artifact("Selection-rule figure data", "Selection-rule condition estimands", "Figure-generation data", "results/figure_data/rerun_v2/selection_rule_robustness/selection_rule_condition_estimands.csv"),
        Artifact("Selection-rule figure data", "Selection-rule contrasts", "Figure-generation data", "results/figure_data/rerun_v2/selection_rule_robustness/selection_rule_contrasts.csv"),
    ])

    artifacts.extend([
        Artifact("Threshold-robustness tables", "Threshold condition estimands", "Table/figure data", "results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_condition_estimands.csv"),
        Artifact("Threshold-robustness tables", "Threshold contrasts", "Table/figure data", "results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_contrasts.csv"),
        Artifact("Threshold-robustness figure data", "Threshold condition estimands", "Figure-generation data", "results/figure_data/rerun_v2/threshold_robustness_checkpointed/threshold_condition_estimands.csv"),
        Artifact("Threshold-robustness figure data", "Threshold contrasts", "Figure-generation data", "results/figure_data/rerun_v2/threshold_robustness_checkpointed/threshold_contrasts.csv"),
    ])

    return artifacts


def recommended_manuscript_package() -> List[dict]:
    return [
        {
            "placement": "Main text — model/design figure",
            "candidate": "Conceptual architecture schematic",
            "artifact": "To be drawn separately from model description",
            "notes": "Shows modules, random bridging, boundary spanners, translation, and capacity/load. Not a statistical result.",
        },
        {
            "placement": "Main text — mechanism decomposition",
            "candidate": "Final core mechanism table or compact dot/interval plot",
            "artifact": "results/processed/rerun_v2/final_core/final_core_contrasts.csv",
            "notes": "Core inferential block: RB_low vs BS_low, BS_low vs BS_high, RB_low vs BS_high.",
        },
        {
            "placement": "Main text — translation capability",
            "candidate": "Translation grid line/table",
            "artifact": "results/processed/rerun_v2/translation_grid/translation_grid_condition_estimands.csv",
            "notes": "Shows monotonic decline in RMST and T95 as pi_BS increases.",
        },
        {
            "placement": "Main text — workload/capacity",
            "candidate": "Workload grid line/table",
            "artifact": "results/processed/rerun_v2/workload_grid/workload_grid_condition_estimands.csv",
            "notes": "Shows lower delay as b increases and per-spanner workload decreases.",
        },
        {
            "placement": "Main text — design-map synthesis",
            "candidate": "Mini heatmap",
            "artifact": "figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.pdf",
            "notes": "Visual synthesis only; do not present as independent bootstrapped causal evidence.",
        },
        {
            "placement": "Appendix or robustness subsection",
            "candidate": "Selection-rule robustness table",
            "artifact": "results/processed/rerun_v2/selection_rule_robustness/selection_rule_contrasts.csv",
            "notes": "Supports actor-capacity interpretation: BS_low penalty disappears under edge-uniform.",
        },
        {
            "placement": "Appendix or robustness subsection",
            "candidate": "Threshold-robustness table",
            "artifact": "results/processed/rerun_v2/threshold_robustness_checkpointed/threshold_contrasts.csv",
            "notes": "Report hardest-tie censoring and non-estimable event quantiles carefully.",
        },
    ]


def status_for(path: Path) -> str:
    return "OK" if path.exists() else "MISSING"


def write_index(repo_root: Path, output_file: Path, artifacts: Iterable[Artifact]) -> int:
    artifacts = list(artifacts)
    missing = [a for a in artifacts if a.required and not (repo_root / a.relative_path).exists()]

    output_file.parent.mkdir(parents=True, exist_ok=True)
    with output_file.open("w", encoding="utf-8") as f:
        f.write("# Final artifact index — rerun_v2\n\n")
        f.write("Generated by `scripts/rerun_v2/build_final_artifact_index.py`.\n\n")
        f.write(f"Generation timestamp: `{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}`.\n\n")

        f.write("## Purpose\n\n")
        f.write(
            "This index lists the manuscript-facing artifacts from the validated rerun_v2 computational track. "
            "It is a packaging aid: it does not run simulations, recompute statistics, or replace the source handovers.\n\n"
        )

        f.write("## Recommended manuscript package\n\n")
        f.write("| Placement | Candidate table/figure | Primary artifact | Notes |\n")
        f.write("|---|---|---|---|\n")
        for row in recommended_manuscript_package():
            f.write(
                f"| {row['placement']} | {row['candidate']} | `{row['artifact']}` | {row['notes']} |\n"
            )

        f.write("\n## Artifact checklist\n\n")
        f.write("| Section | Label | Role | Status | Path |\n")
        f.write("|---|---|---|---|---|\n")
        for artifact in artifacts:
            path = repo_root / artifact.relative_path
            f.write(
                f"| {artifact.section} | {artifact.label} | {artifact.role} | {status_for(path)} | `{artifact.relative_path}` |\n"
            )

        f.write("\n## Summary\n\n")
        f.write(f"- Expected artifacts checked: `{len(artifacts)}`.\n")
        f.write(f"- Required artifacts missing: `{len(missing)}`.\n")
        if missing:
            f.write("\nMissing required artifacts:\n\n")
            for artifact in missing:
                f.write(f"- `{artifact.relative_path}`\n")
        else:
            f.write("- All required artifacts were found.\n")

        f.write("\n## Interpretation guardrails\n\n")
        f.write("- The dependent variable remains time to relational coordination readiness.\n")
        f.write("- Censored trajectories are not converted into artificial event times.\n")
        f.write("- The mini heatmap is a visual design map, not an independently bootstrapped causal test.\n")
        f.write("- Claims should remain at the level of relational delay risk and readiness.\n")

    return len(missing)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build the rerun_v2 final artifact index.")
    parser.add_argument("--repo-root", type=Path, default=repo_root_from_script())
    parser.add_argument("--output", type=Path, default=None)
    parser.add_argument("--strict", action="store_true", help="Exit with code 1 if required artifacts are missing.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    output = args.output
    if output is None:
        output = repo_root / "docs" / "final_artifact_index.md"
    elif not output.is_absolute():
        output = repo_root / output

    missing_count = write_index(repo_root, output, expected_artifacts())

    print("\n============================================")
    print("RERUN V2 FINAL ARTIFACT INDEX")
    print("============================================")
    print(f"repo_root: {repo_root}")
    print(f"output: {output}")
    print(f"missing required artifacts: {missing_count}")
    if missing_count == 0:
        print("All required artifacts found.")
    elif args.strict:
        print("Strict mode failed because required artifacts are missing.")
        return 1
    else:
        print("Index written with missing-artifact warnings.")
    print("============================================")
    print("RERUN V2 FINAL ARTIFACT INDEX PASSED")
    print("============================================")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Smoke test for repository-level reproducibility documentation."""

from __future__ import annotations

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
README = REPO_ROOT / "README.md"
REQUIREMENTS = REPO_ROOT / "requirements.txt"


def main() -> int:
    assert README.exists(), "README.md must exist."
    assert REQUIREMENTS.exists(), "requirements.txt must exist."

    text = README.read_text(encoding="utf-8")
    required_phrases = [
        "Boundary-spanning relational readiness",
        "rerun/balanced-survival-bootstrap",
        "GNU Octave",
        "Python",
        "run_final_core_production",
        "run_translation_grid_production",
        "run_workload_grid_production",
        "run_selection_rule_robustness",
        "run_readiness_threshold_checkpointed",
        "run_mini_heatmap_production",
        "build_manuscript_results_handover",
        "build_final_artifact_index.py --strict",
        "relational coordination readiness",
        "not R&D performance",
    ]

    for phrase in required_phrases:
        assert phrase in text, f"README missing required phrase: {phrase}"

    requirements = REQUIREMENTS.read_text(encoding="utf-8")
    for package in ["numpy", "pandas", "matplotlib"]:
        assert package in requirements, f"requirements.txt missing package: {package}"

    print("ALL RERUN V2 REPRODUCIBILITY DOC TESTS PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

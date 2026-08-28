#!/usr/bin/env python3
"""Smoke tests for the rerun_v2 computational closure builder."""

from __future__ import annotations

import importlib.util
import shutil
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT_PATH = REPO_ROOT / "scripts" / "rerun_v2" / "build_computational_closure.py"
TEST_ROOT = REPO_ROOT / "results" / "processed" / "rerun_v2" / "computational_closure_test"


def load_module():
    module_name = "build_computational_closure"
    spec = importlib.util.spec_from_file_location(module_name, SCRIPT_PATH)
    assert spec is not None and spec.loader is not None, "Could not load closure script."
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def touch_text(path: Path, text: str = "synthetic artifact\n") -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def main() -> int:
    assert SCRIPT_PATH.exists(), f"Missing script: {SCRIPT_PATH}"
    module = load_module()

    if TEST_ROOT.exists():
        shutil.rmtree(TEST_ROOT)
    TEST_ROOT.mkdir(parents=True)

    synthetic_repo = TEST_ROOT / "synthetic_repo"
    synthetic_repo.mkdir(parents=True)

    for check in module.default_checks():
        touch_text(synthetic_repo / check.relative_path)

    touch_text(
        synthetic_repo / "docs" / "manuscript_results_handover.md",
        "Mini heatmap synthesis\nDo not claim improved R&D performance\n"
        "Censored trajectories are not converted into artificial event times\n",
    )
    touch_text(
        synthetic_repo / "docs" / "final_artifact_index.md",
        "Final artifact index\nRequired artifacts missing: `0`\nRecommended manuscript package\n",
    )
    touch_text(
        synthetic_repo / "README.md",
        "relational coordination readiness\nnot R&D performance\nrequirements.txt\n",
    )

    output = TEST_ROOT / "computational_track_closure_test.md"
    cmd = [
        sys.executable,
        str(SCRIPT_PATH),
        "--repo-root",
        str(synthetic_repo),
        "--output",
        str(output),
        "--strict",
    ]
    result = subprocess.run(cmd, cwd=REPO_ROOT, text=True, capture_output=True)
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
    assert result.returncode == 0, "Computational closure script failed in strict synthetic mode."
    assert output.exists(), "Computational closure output was not created."

    text = output.read_text(encoding="utf-8")
    assert "Computational track closure" in text, "Output should contain closure title."
    assert "Status: closed for manuscript writing" in text, "Output should indicate closure."
    assert "Required artifacts missing: `0`" in text, "Synthetic strict test should have no missing artifacts."
    assert "Phrase-check warnings: `0`" in text, "Synthetic strict test should have no phrase warnings."
    assert "mini heatmap synthesis" in text, "Closure should mention mini heatmap synthesis."

    print("ALL RERUN V2 COMPUTATIONAL CLOSURE TESTS PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

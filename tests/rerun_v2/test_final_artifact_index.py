#!/usr/bin/env python3
"""Smoke tests for the rerun_v2 final artifact index builder."""

from __future__ import annotations

import importlib.util
import shutil
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT_PATH = REPO_ROOT / "scripts" / "rerun_v2" / "build_final_artifact_index.py"
TEST_ROOT = REPO_ROOT / "results" / "processed" / "rerun_v2" / "final_artifact_index_test"


def load_module():
    module_name = "build_final_artifact_index"
    spec = importlib.util.spec_from_file_location(module_name, SCRIPT_PATH)
    assert spec is not None and spec.loader is not None, "Could not load final artifact index script."
    module = importlib.util.module_from_spec(spec)

    # Python 3.13 dataclasses expect dynamically imported modules to be present
    # in sys.modules while class decorators are evaluated.
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def touch(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("synthetic artifact\n", encoding="utf-8")


def main() -> int:
    assert SCRIPT_PATH.exists(), f"Missing script: {SCRIPT_PATH}"

    module = load_module()
    artifacts = module.expected_artifacts()
    assert len(artifacts) >= 30, "Expected a substantial artifact inventory."
    assert any(a.relative_path.endswith("mini_heatmap_rmst_heatmap.pdf") for a in artifacts), (
        "Mini heatmap PDF must be included in the final artifact index."
    )
    assert any(a.relative_path == "docs/manuscript_results_handover.md" for a in artifacts), (
        "Master handover must be included in the final artifact index."
    )

    if TEST_ROOT.exists():
        shutil.rmtree(TEST_ROOT)
    TEST_ROOT.mkdir(parents=True)

    synthetic_repo = TEST_ROOT / "synthetic_repo"
    synthetic_repo.mkdir(parents=True)

    for artifact in artifacts:
        touch(synthetic_repo / artifact.relative_path)

    output = TEST_ROOT / "final_artifact_index_test.md"
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
    assert result.returncode == 0, "Final artifact index script failed in strict synthetic mode."
    assert output.exists(), "Final artifact index output was not created."

    text = output.read_text(encoding="utf-8")
    assert "Final artifact index" in text, "Output should contain title."
    assert "Recommended manuscript package" in text, "Output should contain manuscript package section."
    assert "Mini heatmap" in text, "Output should include mini heatmap package entry."
    assert "Required artifacts missing: `0`" in text, "Synthetic strict test should have no missing artifacts."

    print("ALL RERUN V2 FINAL ARTIFACT INDEX TESTS PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

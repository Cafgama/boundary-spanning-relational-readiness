#!/usr/bin/env python3
"""Smoke test for scripts/rerun_v2/plot_mini_heatmap.py."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


def repo_root_from_test() -> Path:
    return Path(__file__).resolve().parents[2]


def write_synthetic_matrix_csv(path: Path) -> None:
    path.write_text(
        "\n".join(
            [
                "metric,b,load_per_spanner,pi_BS_0.55,pi_BS_0.70",
                "RMST,1,6.000000,9000.000000,4000.000000",
                "RMST,2,3.000000,8000.000000,3500.000000",
            ]
        )
        + "\n",
        encoding="utf-8",
    )


def main() -> int:
    repo_root = repo_root_from_test()
    script = repo_root / "scripts" / "rerun_v2" / "plot_mini_heatmap.py"
    assert script.exists(), f"Missing plotting script: {script}"

    with TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        input_csv = tmp_dir / "mini_heatmap_matrix_RMST.csv"
        output_dir = tmp_dir / "figures"
        write_synthetic_matrix_csv(input_csv)

        completed = subprocess.run(
            [
                sys.executable,
                str(script),
                "--input",
                str(input_csv),
                "--output-dir",
                str(output_dir),
                "--no-pdf",
            ],
            cwd=str(repo_root),
            text=True,
            capture_output=True,
            check=False,
        )

        if completed.returncode != 0:
            print(completed.stdout)
            print(completed.stderr)
        assert completed.returncode == 0, "Plotting script failed."
        assert "RERUN V2 MINI HEATMAP FIGURE PASSED" in completed.stdout

        png = output_dir / "mini_heatmap_rmst_heatmap.png"
        caption = output_dir / "mini_heatmap_rmst_heatmap_caption.txt"
        assert png.exists(), "PNG output was not created."
        assert caption.exists(), "Caption output was not created."
        assert png.stat().st_size > 0, "PNG output is empty."
        assert "Mini heatmap" in caption.read_text(encoding="utf-8")

    print("ALL RERUN V2 MINI HEATMAP FIGURE TESTS PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

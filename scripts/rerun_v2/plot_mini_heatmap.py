#!/usr/bin/env python3
"""
Plot the rerun_v2 mini heatmap for translation capability x boundary-spanner workload.

Default input:
  results/figure_data/rerun_v2/mini_heatmap/mini_heatmap_matrix_RMST.csv

Default outputs:
  figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.png
  figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap.pdf
  figures/rerun_v2/mini_heatmap/mini_heatmap_rmst_heatmap_caption.txt

This script does not run simulations. It only reads the audited CSV exported by
experiments/rerun_v2/analyze_mini_heatmap_results.m.
"""

from __future__ import annotations

import argparse
import csv
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


@dataclass(frozen=True)
class HeatmapData:
    metric: str
    pi_bs_values: List[float]
    b_values: List[int]
    load_values: List[float]
    values: np.ndarray


def repo_root_from_script() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_float(value: str) -> float:
    value = value.strip()
    if value == "":
        return math.nan
    return float(value)


def parse_pi_header(header: str) -> float:
    prefix = "pi_BS_"
    if not header.startswith(prefix):
        raise ValueError(f"Expected pi_BS_* column, got: {header}")
    return float(header[len(prefix) :])


def read_matrix_csv(path: Path) -> HeatmapData:
    if not path.exists():
        raise FileNotFoundError(
            f"Input CSV not found: {path}. Run analyze_mini_heatmap_results first."
        )

    with path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        try:
            header = next(reader)
        except StopIteration as exc:
            raise ValueError(f"Input CSV is empty: {path}") from exc

        expected_prefix = ["metric", "b", "load_per_spanner"]
        if header[:3] != expected_prefix:
            raise ValueError(
                f"Unexpected header in {path}: first columns must be {expected_prefix}, got {header[:3]}"
            )

        pi_bs_values = [parse_pi_header(h) for h in header[3:]]
        rows = list(reader)

    if not rows:
        raise ValueError(f"Input CSV has no data rows: {path}")

    metric_names = []
    b_values: List[int] = []
    load_values: List[float] = []
    matrix_rows: List[List[float]] = []

    for row in rows:
        if len(row) != len(header):
            raise ValueError(
                f"Row length mismatch in {path}: expected {len(header)}, got {len(row)} for row {row}"
            )
        metric_names.append(row[0])
        b_values.append(int(row[1]))
        load_values.append(float(row[2]))
        matrix_rows.append([parse_float(x) for x in row[3:]])

    unique_metrics = sorted(set(metric_names))
    if len(unique_metrics) != 1:
        raise ValueError(f"Expected one metric in matrix CSV, got: {unique_metrics}")

    values = np.array(matrix_rows, dtype=float)
    if values.shape != (len(b_values), len(pi_bs_values)):
        raise ValueError("Internal matrix shape mismatch.")

    return HeatmapData(
        metric=unique_metrics[0],
        pi_bs_values=pi_bs_values,
        b_values=b_values,
        load_values=load_values,
        values=values,
    )


def check_monotonicity(data: HeatmapData) -> List[str]:
    warnings: List[str] = []

    for row_idx, b in enumerate(data.b_values):
        row = data.values[row_idx, :]
        finite_row = row[np.isfinite(row)]
        if len(finite_row) >= 2 and np.any(np.diff(finite_row) > 0):
            warnings.append(f"RMST is not weakly decreasing in pi_BS for b={b}.")

    for col_idx, pi_bs in enumerate(data.pi_bs_values):
        col = data.values[:, col_idx]
        finite_col = col[np.isfinite(col)]
        if len(finite_col) >= 2 and np.any(np.diff(finite_col) > 0):
            warnings.append(f"RMST is not weakly decreasing in b for pi_BS={pi_bs:.2f}.")

    return warnings


def format_number(value: float) -> str:
    if not np.isfinite(value):
        return "n/a"
    return f"{value:,.0f}"


def make_heatmap(data: HeatmapData, output_dir: Path, make_pdf: bool = True) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)

    fig, ax = plt.subplots(figsize=(6.6, 4.8))
    image = ax.imshow(data.values, aspect="auto")

    ax.set_xticks(np.arange(len(data.pi_bs_values)))
    ax.set_xticklabels([f"{x:.2f}" for x in data.pi_bs_values])
    ax.set_xlabel("Boundary-spanner translation capability ($\\pi_{BS}$)")

    ax.set_yticks(np.arange(len(data.b_values)))
    ax.set_yticklabels(
        [f"b={b}\nload={load:g}" for b, load in zip(data.b_values, data.load_values)]
    )
    ax.set_ylabel("Boundary-spanner capacity per side")

    ax.set_title("Mini heatmap of relational-readiness delay")

    for row_idx in range(data.values.shape[0]):
        for col_idx in range(data.values.shape[1]):
            ax.text(
                col_idx,
                row_idx,
                format_number(data.values[row_idx, col_idx]),
                ha="center",
                va="center",
                fontsize=9,
            )

    cbar = fig.colorbar(image, ax=ax)
    cbar.set_label("RMST: expected time without readiness; lower is faster")

    fig.tight_layout()

    png_path = output_dir / "mini_heatmap_rmst_heatmap.png"
    pdf_path = output_dir / "mini_heatmap_rmst_heatmap.pdf"
    caption_path = output_dir / "mini_heatmap_rmst_heatmap_caption.txt"

    fig.savefig(png_path, dpi=300, bbox_inches="tight")
    if make_pdf:
        fig.savefig(pdf_path, bbox_inches="tight")
    plt.close(fig)

    caption = build_caption(data)
    caption_path.write_text(caption, encoding="utf-8")

    outputs = {"png": png_path, "caption": caption_path}
    if make_pdf:
        outputs["pdf"] = pdf_path
    return outputs


def build_caption(data: HeatmapData) -> str:
    worst = float(np.nanmax(data.values))
    best = float(np.nanmin(data.values))
    improvement = worst - best

    return (
        "Figure X. Mini heatmap of time to relational coordination readiness across "
        "boundary-spanner translation capability and role capacity. Cell values report "
        "RMST, interpreted as expected time without readiness within the observation "
        "horizon; lower values indicate faster relational-readiness formation. The map "
        "is a visual synthesis of the translation and workload mechanisms, not a new "
        "causal identification strategy. In the tested grid, RMST decreases as translation "
        "capability increases and as the same cross-boundary tie budget is distributed "
        "across more boundary spanners. The difference between the highest-delay and "
        f"lowest-delay cells is approximately {improvement:,.0f} model time steps.\n"
    )


def default_paths(repo_root: Path) -> tuple[Path, Path]:
    input_csv = (
        repo_root
        / "results"
        / "figure_data"
        / "rerun_v2"
        / "mini_heatmap"
        / "mini_heatmap_matrix_RMST.csv"
    )
    output_dir = repo_root / "figures" / "rerun_v2" / "mini_heatmap"
    return input_csv, output_dir


def build_arg_parser() -> argparse.ArgumentParser:
    repo_root = repo_root_from_script()
    default_input, default_output_dir = default_paths(repo_root)

    parser = argparse.ArgumentParser(
        description="Plot the rerun_v2 mini heatmap from exported figure-data CSVs."
    )
    parser.add_argument(
        "--input",
        type=Path,
        default=default_input,
        help="Path to mini_heatmap_matrix_RMST.csv.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=default_output_dir,
        help="Directory where figure files will be written.",
    )
    parser.add_argument(
        "--no-pdf",
        action="store_true",
        help="Write PNG and caption only; skip PDF export.",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    data = read_matrix_csv(args.input)
    warnings = check_monotonicity(data)
    outputs = make_heatmap(data, args.output_dir, make_pdf=not args.no_pdf)

    print("RERUN V2 MINI HEATMAP FIGURE PASSED")
    print(f"Input CSV: {args.input}")
    for key, path in outputs.items():
        print(f"{key}: {path}")

    if warnings:
        print("Warnings:")
        for warning in warnings:
            print(f"- {warning}")
    else:
        print("No monotonicity warnings.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

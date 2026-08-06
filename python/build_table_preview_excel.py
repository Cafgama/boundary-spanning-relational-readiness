# build_table_preview_excel.py
# Creates a human-readable Excel workbook with one sheet per manuscript table.
#
# Run from project root:
#   python python/build_table_preview_excel.py
#
# Inputs:
#   results/table_data/table_*.csv
#
# Output:
#   tables/table_preview_workbook.xlsx

from __future__ import annotations

from pathlib import Path
import csv

from artifact_tool import Workbook, SpreadsheetFile


try:
    ROOT = Path(__file__).resolve().parents[1]
except NameError:
    ROOT = Path.cwd()
    if not (ROOT / "results" / "table_data").exists() and (ROOT.parent / "results" / "table_data").exists():
        ROOT = ROOT.parent

INPUT_DIR = ROOT / "results" / "table_data"
OUTPUT_DIR = ROOT / "tables"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_FILE = OUTPUT_DIR / "table_preview_workbook.xlsx"

if not INPUT_DIR.exists():
    raise FileNotFoundError(f"Missing table-data folder: {INPUT_DIR}")


def read_csv_dict(name: str) -> list[dict[str, str]]:
    path = INPUT_DIR / name
    if not path.exists():
        raise FileNotFoundError(f"Missing required input file: {path}")
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def to_num(value):
    if value is None or value == "":
        return None
    try:
        return float(value)
    except Exception:
        return value


def to_rate(value):
    return to_num(value)


def pct_value_to_rate(value):
    value = to_num(value)
    if value is None:
        return None
    return value / 100.0


def col_letter(n: int) -> str:
    s = ""
    while n:
        n, rem = divmod(n - 1, 26)
        s = chr(65 + rem) + s
    return s


def safe_table_name(name: str) -> str:
    return "".join(ch for ch in name if ch.isalnum())[:30]


def write_sheet(
    wb,
    name: str,
    title: str,
    caption: str,
    headers: list[str],
    rows: list[list],
    number_formats: dict[int, str] | None = None,
    table_name: str | None = None,
    widths: dict[int, int] | None = None,
):
    sheet = wb.worksheets.add(name)
    ncols = len(headers)
    end_col = col_letter(ncols)

    # Title
    sheet.get_range(f"A1:{end_col}1").values = [[title] + [""] * (ncols - 1)]
    try:
        sheet.merge_cells(f"A1:{end_col}1")
    except Exception:
        pass
    sheet.get_range("A1").format = {
        "font": {"bold": True, "size": 14, "color": "#0F172A"},
        "fill": "#E2E8F0",
        "horizontal_alignment": "left",
        "vertical_alignment": "center",
        "row_height": 28,
    }

    # Caption
    sheet.get_range(f"A2:{end_col}2").values = [[caption] + [""] * (ncols - 1)]
    try:
        sheet.merge_cells(f"A2:{end_col}2")
    except Exception:
        pass
    sheet.get_range("A2").format = {
        "font": {"italic": True, "size": 10, "color": "#475569"},
        "wrap_text": True,
        "vertical_alignment": "top",
        "row_height": 42,
    }

    # Table body
    start_row = 4
    matrix = [headers] + rows
    end_row = start_row + len(matrix) - 1
    rng = sheet.get_range(f"A{start_row}:{end_col}{end_row}")
    rng.values = matrix

    sheet.get_range(f"A{start_row}:{end_col}{start_row}").format = {
        "fill": "#0F766E",
        "font": {"bold": True, "color": "#FFFFFF"},
        "horizontal_alignment": "center",
        "vertical_alignment": "center",
        "wrap_text": True,
        "row_height": 34,
    }

    if rows:
        sheet.get_range(f"A{start_row + 1}:{end_col}{end_row}").format = {
            "wrap_text": True,
            "vertical_alignment": "top",
            "font": {"size": 10},
        }

    if number_formats:
        for col_idx, fmt in number_formats.items():
            c = col_letter(col_idx)
            sheet.get_range(f"{c}{start_row + 1}:{c}{end_row}").format.number_format = fmt

    if table_name:
        try:
            sheet.tables.add(f"A{start_row}:{end_col}{end_row}", True, safe_table_name(table_name))
        except Exception as exc:
            print(f"Warning: could not add Excel table {table_name}: {exc}")

    try:
        sheet.freeze_panes.freeze_rows(start_row)
    except Exception:
        pass

    if widths:
        for col_idx, width in widths.items():
            c = col_letter(col_idx)
            sheet.get_range(f"{c}:{c}").format.column_width = width
    else:
        try:
            rng.format.autofit_columns()
        except Exception:
            pass


def main() -> None:
    print(f"Project root: {ROOT}")
    print(f"Input: {INPUT_DIR}")
    print(f"Output: {OUTPUT_FILE}")

    wb = Workbook.create()

    # Index
    index_headers = ["Table", "Sheet", "Source", "Purpose / placement"]
    index_rows = [
        ["Table 1", "01_Constructs", "table_01_constructs.csv", "Section 2.5 or start of Section 3"],
        ["Table 2", "02_Parameters", "table_02_baseline_parameters.csv", "Section 3.7"],
        ["Table 3", "03_Experiments", "table_03_experimental_design.csv", "Section 3.8"],
        ["Table 4", "04_Baseline", "table_04_baseline_architecture.csv", "Section 4.1"],
        ["Table 5", "05_Mechanism", "table_05_mechanism_decomposition.csv", "Sections 4.2 and 4.3"],
        ["Table 6", "06_Translation", "table_06_translation_capability.csv", "Section 4.6 or appendix"],
        ["Table 7", "07_Load", "table_07_boundary_spanner_load.csv", "Section 4.5"],
        ["Table 8", "08_Selection", "table_08_selection_rule_robustness.csv", "Appendix"],
        ["Table 9", "09_Thresholds", "table_09_readiness_threshold_robustness.csv", "Appendix"],
    ]
    write_sheet(
        wb,
        "00_Index",
        "Table preview workbook",
        "Human-readable Excel preview generated from the same table-data layer used by the LaTeX pipeline.",
        index_headers,
        index_rows,
        table_name="IndexTable",
        widths={1: 12, 2: 22, 3: 38, 4: 54},
    )

    # Table 1
    t1 = sorted(read_csv_dict("table_01_constructs.csv"), key=lambda r: int(r["row_order"]))
    write_sheet(
        wb,
        "01_Constructs",
        "Table 1. Model constructs and managerial interpretation",
        "Conceptual mapping between model objects and managerial interpretation.",
        ["Construct", "Formal representation", "Managerial interpretation"],
        [[r["construct"], r["formal_representation"], r["managerial_interpretation"]] for r in t1],
        table_name="ConstructsTable",
        widths={1: 24, 2: 28, 3: 72},
    )

    # Table 2
    t2 = sorted(read_csv_dict("table_02_baseline_parameters.csv"), key=lambda r: int(r["row_order"]))
    write_sheet(
        wb,
        "02_Parameters",
        "Table 2. Baseline parameterization of the simulation model",
        "Reference-case parameters used in the baseline simulation design.",
        ["Parameter", "Meaning", "Value", "Managerial rationale"],
        [[r["parameter"], r["meaning"], to_num(r["value"]), r["managerial_rationale"]] for r in t2],
        number_formats={3: "0.00"},
        table_name="ParametersTable",
        widths={1: 14, 2: 34, 3: 14, 4: 68},
    )

    # Table 3
    t3 = sorted(read_csv_dict("table_03_experimental_design.csv"), key=lambda r: int(r["row_order"]))
    write_sheet(
        wb,
        "03_Experiments",
        "Table 3. Experimental design and managerial questions",
        "Simulation blocks and the managerial question each block addresses.",
        ["Experiment", "Conditions", "Managerial question"],
        [[r["experiment"], r["conditions"], r["managerial_question"]] for r in t3],
        table_name="ExperimentsTable",
        widths={1: 32, 2: 50, 3: 72},
    )

    # Table 4
    t4 = read_csv_dict("table_04_baseline_architecture.csv")
    write_sheet(
        wb,
        "04_Baseline",
        "Table 4. Baseline architecture comparison",
        "Graph-level summaries of first-passage time to relational coordination readiness.",
        ["Architecture", "Mean T", "Median T", "P90", "P95", "Convergence"],
        [[r["architecture_label"], to_num(r["mean_T"]), to_num(r["median_T"]), to_num(r["p90_T"]), to_num(r["p95_T"]), to_rate(r["convergence_rate"])] for r in t4],
        number_formats={2: "#,##0.0", 3: "#,##0.0", 4: "#,##0.0", 5: "#,##0.0", 6: "0%"},
        table_name="BaselineTable",
        widths={1: 32, 2: 14, 3: 14, 4: 14, 5: 14, 6: 14},
    )

    # Table 5
    t5 = read_csv_dict("table_05_mechanism_decomposition.csv")
    write_sheet(
        wb,
        "05_Mechanism",
        "Table 5. Mechanism decomposition",
        "Comparison of concentration without translation, translation capability, and total boundary-spanning effect.",
        ["Comparison", "Statistic", "X", "Y", "X value", "Y value", "X minus Y", "CI low", "CI high", "Reduction", "Paired"],
        [[r["comparison_label"], r["statistic"], r["condition_x"], r["condition_y"], to_num(r["x_value"]), to_num(r["y_value"]), to_num(r["difference_x_minus_y"]), to_num(r["ci_low"]), to_num(r["ci_high"]), pct_value_to_rate(r["reduction_pct"]), to_num(r["paired"])] for r in t5],
        number_formats={5: "#,##0.0", 6: "#,##0.0", 7: "#,##0.0", 8: "#,##0.0", 9: "#,##0.0", 10: "0.0%", 11: "0"},
        table_name="MechanismTable",
        widths={1: 36, 2: 14, 3: 12, 4: 12, 5: 14, 6: 14, 7: 14, 8: 14, 9: 14, 10: 14, 11: 10},
    )

    # Table 6
    t6 = sorted(read_csv_dict("table_06_translation_capability.csv"), key=lambda r: float(r["pi_BS"]))
    write_sheet(
        wb,
        "06_Translation",
        "Table 6. Translation-capability robustness",
        "Boundary-spanning readiness time as translation capability increases.",
        ["pi_BS", "Mean T", "Median T", "P90", "P95"],
        [[to_num(r["pi_BS"]), to_num(r["mean_T"]), to_num(r["median_T"]), to_num(r["p90_T"]), to_num(r["p95_T"])] for r in t6],
        number_formats={1: "0.00", 2: "#,##0.0", 3: "#,##0.0", 4: "#,##0.0", 5: "#,##0.0"},
        table_name="TranslationTable",
        widths={1: 14, 2: 14, 3: 14, 4: 14, 5: 14},
    )

    # Table 7
    t7 = sorted(read_csv_dict("table_07_boundary_spanner_load.csv"), key=lambda r: float(r["b"]))
    write_sheet(
        wb,
        "07_Load",
        "Table 7. Boundary-spanner load and readiness delay",
        "Readiness time under alternative boundary-spanner capacity levels.",
        ["b", "Load k/(2b)", "Mean T", "Median T", "P90", "P95"],
        [[to_num(r["b"]), to_num(r["load_per_spanner"]), to_num(r["mean_T"]), to_num(r["median_T"]), to_num(r["p90_T"]), to_num(r["p95_T"])] for r in t7],
        number_formats={1: "0", 2: "0.0", 3: "#,##0.0", 4: "#,##0.0", 5: "#,##0.0", 6: "#,##0.0"},
        table_name="LoadTable",
        widths={1: 12, 2: 16, 3: 14, 4: 14, 5: 14, 6: 14},
    )

    # Table 8
    rule_label = {"agent_first": "Agent-first", "edge_uniform": "Edge-uniform"}
    t8 = read_csv_dict("table_08_selection_rule_robustness.csv")
    write_sheet(
        wb,
        "08_Selection",
        "Table 8. Interaction-selection robustness",
        "Agent-first versus edge-uniform activation.",
        ["Condition", "Selection rule", "Mean T", "Median T", "P90", "P95"],
        [[r["condition"], rule_label.get(r["selection_rule"], r["selection_rule"]), to_num(r["mean_T"]), to_num(r["median_T"]), to_num(r["p90_T"]), to_num(r["p95_T"])] for r in t8],
        number_formats={3: "#,##0.0", 4: "#,##0.0", 5: "#,##0.0", 6: "#,##0.0"},
        table_name="SelectionTable",
        widths={1: 16, 2: 20, 3: 14, 4: 14, 5: 14, 6: 14},
    )

    # Table 9
    scenario_order = {"TH_075_Q_080": 1, "TH_080_Q_070": 2, "TH_080_Q_080": 3, "TH_080_Q_090": 4, "TH_085_Q_080": 5}
    t9 = sorted(read_csv_dict("table_09_readiness_threshold_robustness.csv"), key=lambda r: scenario_order.get(r["scenario_code"], 99))
    write_sheet(
        wb,
        "09_Thresholds",
        "Table 9. Readiness-threshold robustness",
        "Translation-capability robustness under alternative tie-level and boundary-level readiness thresholds.",
        ["Scenario", "theta", "q", "BS_low conv.", "BS_high conv.", "BS_low P95", "BS_high P95", "P95 difference", "CI low", "CI high", "Reduction"],
        [[r["scenario_label"], to_num(r["theta"]), to_num(r["q"]), to_rate(r["BS_low_convergence_rate"]), to_rate(r["BS_high_convergence_rate"]), to_num(r["BS_low_p95_T"]), to_num(r["BS_high_p95_T"]), to_num(r["p95_difference"]), to_num(r["p95_ci_low"]), to_num(r["p95_ci_high"]), pct_value_to_rate(r["p95_reduction_pct"])] for r in t9],
        number_formats={2: "0.00", 3: "0.00", 4: "0%", 5: "0%", 6: "#,##0.0", 7: "#,##0.0", 8: "#,##0.0", 9: "#,##0.0", 10: "#,##0.0", 11: "0.0%"},
        table_name="ThresholdsTable",
        widths={1: 28, 2: 10, 3: 10, 4: 14, 5: 16, 6: 14, 7: 14, 8: 14, 9: 14, 10: 14, 11: 14},
    )

    error_scan = wb.inspect({
        "kind": "match",
        "search_term": "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
        "options": {"use_regex": True, "max_results": 100},
        "summary": "formula error scan",
    })
    print(error_scan.ndjson)

    SpreadsheetFile.export_xlsx(wb).save(str(OUTPUT_FILE))
    print(f"Saved: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()

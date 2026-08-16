"""Validate the generated rule matrix and generated Stata source."""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


REQUIRED_FIELDS = {
    "rule_id",
    "section_code",
    "variable",
    "data_variables",
    "check_type",
    "condition_status",
    "source_regle",
    "scope_stata",
    "scope_source",
    "scope_status",
    "decision_status",
    "action",
    "script",
}
FORBIDDEN_EXECUTABLE = (".InList(", ".Contains(", "&&", "||", "DateTime", "$neSaitPas")


def active_stata_lines(path: Path):
    in_block_comment = False
    for line_number, line in enumerate(
        path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1
    ):
        remaining = line
        while remaining:
            if in_block_comment:
                end = remaining.find("*/")
                if end < 0:
                    remaining = ""
                    continue
                in_block_comment = False
                remaining = remaining[end + 2 :]
                continue
            start = remaining.find("/*")
            if start < 0:
                stripped = remaining.lstrip()
                if stripped and not stripped.startswith(("*", "//")):
                    yield line_number, remaining
                remaining = ""
                continue
            before = remaining[:start]
            if before.strip() and not before.lstrip().startswith(("*", "//")):
                yield line_number, before
            in_block_comment = True
            remaining = remaining[start + 2 :]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", required=True)
    args = parser.parse_args()
    project_root = Path(args.project_root).resolve()
    matrix_path = project_root / "generated" / "apurement_rule_matrix.csv"
    questionnaire_path = project_root / "generated" / "questionnaire_rules.csv"
    dictionary_path = project_root / "generated" / "dictionnaire_variables.csv"
    generated_program = project_root / "program" / "generated"

    with matrix_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        fields = set(reader.fieldnames or [])
        rows = list(reader)
    missing_fields = REQUIRED_FIELDS - fields
    if missing_fields:
        raise SystemExit(f"Colonnes requises absentes : {sorted(missing_fields)}")
    if not rows:
        raise SystemExit("La matrice de regles est vide.")

    rule_ids = [row["rule_id"] for row in rows]
    duplicates = sorted({rule_id for rule_id in rule_ids if rule_ids.count(rule_id) > 1})
    if duplicates:
        raise SystemExit(f"Identifiants de regles dupliques : {duplicates[:10]}")

    invalid = [
        row["rule_id"]
        for row in rows
        if not row["source_regle"]
        or not row["scope_source"]
        or not row["scope_status"]
        or not row["decision_status"]
        or not row["action"]
    ]
    if invalid:
        raise SystemExit(f"Regles sans provenance/statut/action : {invalid[:10]}")

    with dictionary_path.open("r", encoding="utf-8-sig", newline="") as handle:
        dictionary_rows = list(csv.DictReader(handle))
    dictionary_variables = {row["variable"] for row in dictionary_rows}
    unknown_data_variables = sorted(
        {
            variable
            for row in rows
            for variable in row["data_variables"].split("|")
            if variable and variable not in dictionary_variables
        }
    )
    if unknown_data_variables:
        raise SystemExit(
            "Variables de matrice absentes du dictionnaire : "
            + ", ".join(unknown_data_variables[:20])
        )

    pii_leaks = [
        row["variable"]
        for row in dictionary_rows
        if row.get("pii_restricted", "").lower() == "true"
        and (
            row.get("observed_values_sample") != "[REDACTED]"
            or row.get("min_observed")
            or row.get("max_observed")
        )
    ]
    if pii_leaks:
        raise SystemExit(
            "Valeurs sensibles non expurgees du dictionnaire : "
            + ", ".join(pii_leaks)
        )

    with questionnaire_path.open("r", encoding="utf-8-sig", newline="") as handle:
        questionnaire_rows = list(csv.DictReader(handle))
    covered = {row["variable"].lower() for row in rows}
    missing_variables = sorted(
        {
            row["variable"]
            for row in questionnaire_rows
            if row["variable"].lower() not in covered
        }
    )
    if missing_variables:
        raise SystemExit(
            "Objets questionnaire absents de la matrice : "
            + ", ".join(missing_variables[:20])
        )

    source_issues: list[str] = []
    for path in sorted(generated_program.glob("04_*.do")):
        brace_balance = 0
        for line_number, line in active_stata_lines(path):
            brace_balance += line.count("{") - line.count("}")
            for token in FORBIDDEN_EXECUTABLE:
                if token in line:
                    source_issues.append(
                        f"{path.name}:{line_number}: token non traduit {token}"
                    )
        if brace_balance != 0:
            source_issues.append(f"{path.name}: accolades desequilibrees")
    if source_issues:
        print("Problemes dans les do-files generes :")
        print("\n".join(source_issues))
        return 1

    review_count = sum(row["condition_status"] == "A_VALIDER" for row in rows)
    executable_count = sum(bool(row.get("rule_expression_stata")) for row in rows)
    print(
        f"Rule matrix validation: OK ({len(rows)} regles, "
        f"{executable_count} executables, {review_count} A_VALIDER)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

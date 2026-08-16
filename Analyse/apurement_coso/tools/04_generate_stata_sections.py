"""Generate ENE-style Stata diagnostics from questionnaire and data metadata."""

from __future__ import annotations

import argparse
import csv
import re
import unicodedata
from collections import defaultdict
from pathlib import Path


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return [
            {key: (value or "").strip() for key, value in row.items()}
            for row in csv.DictReader(handle)
        ]


def ascii_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value or "")
    normalized = normalized.encode("ascii", "ignore").decode("ascii")
    normalized = normalized.replace("`", "'").replace("\r", " ").replace("\n", " ")
    return re.sub(r"\s+", " ", normalized).strip()


def safe_part(value: str, max_length: int = 55) -> str:
    value = re.sub(r"[^A-Za-z0-9_]+", "_", ascii_text(value)).strip("_")
    return (value or "section")[:max_length]


def stata_quote(value: str, max_length: int = 230) -> str:
    value = ascii_text(value)[:max_length].replace('"', "'")
    return f'"{value}"'


def parse_options(value: str) -> list[tuple[str, str]]:
    output: list[tuple[str, str]] = []
    for item in (value or "").split("|"):
        if ":" not in item:
            continue
        code, label = item.split(":", 1)
        code = code.strip()
        if re.fullmatch(r"-?\d+(?:\.\d+)?", code):
            code = str(int(code)) if re.fullmatch(r"-?\d+", code) else code
            output.append((code, label.strip()))
    return output


def inlist_expression(variable: str, codes: list[str]) -> str:
    chunks = [codes[index : index + 10] for index in range(0, len(codes), 10)]
    parts = [f"inlist({variable}, {', '.join(chunk)})" for chunk in chunks if chunk]
    if not parts:
        return "0"
    return "(" + " | ".join(parts) + ")"


def dictionary_maps(
    rows: list[dict[str, str]],
) -> tuple[dict[str, dict[str, str]], dict[str, str], dict[str, list[str]]]:
    by_lower: dict[str, dict[str, str]] = {}
    actual_case: dict[str, str] = {}
    split_roots: dict[str, list[str]] = defaultdict(list)
    for row in rows:
        variable = row["variable"]
        lower = variable.lower()
        if lower in by_lower:
            raise ValueError(f"Variables ambiguës par casse : {variable}")
        by_lower[lower] = row
        actual_case[lower] = variable
        if "__" in variable:
            split_roots[variable.split("__", 1)[0].lower()].append(variable)
    for root in split_roots:
        split_roots[root].sort(key=lambda item: (len(item), item.lower()))
    return by_lower, actual_case, split_roots


def is_string(meta: dict[str, str]) -> bool:
    return "character" in meta.get("r_class", "").lower() or meta.get(
        "storage_type", ""
    ).lower() == "character"


def missing_expression(variable: str, meta: dict[str, str]) -> str:
    if is_string(meta):
        return f'(missing({variable}) | trim({variable}) == "")'
    return f"missing({variable})"


def answered_expression(variable: str, meta: dict[str, str]) -> str:
    if is_string(meta):
        return f'(!missing({variable}) & trim({variable}) != "")'
    return f"!missing({variable})"


RESERVED = {
    "inlist",
    "inrange",
    "missing",
    "trim",
    "real",
    "cond",
    "true",
    "false",
    "self",
}


def guard_nullable_comparisons(expression: str, actual_case: dict[str, str]) -> str:
    """Make Survey Solutions nullable comparisons safe under Stata semantics."""

    pattern = re.compile(
        r"\b([A-Za-z][A-Za-z0-9_]*)\s*(==|!=|>=|<=|>|<)\s*"
        r"([A-Za-z][A-Za-z0-9_]*|-?\d+(?:\.\d+)?)"
    )

    def replace(match: re.Match[str]) -> str:
        left, operator, right = match.groups()
        left_actual = actual_case.get(left.lower())
        if left_actual is None:
            return match.group(0)
        guards = [f"!missing({left_actual})"]
        right_actual = actual_case.get(right.lower())
        right_value = right_actual or right
        if right_actual is not None:
            guards.append(f"!missing({right_actual})")
        return (
            f"({' & '.join(guards)} & "
            f"({left_actual} {operator} {right_value}))"
        )

    return pattern.sub(replace, expression)


def translate_expression(
    raw: str,
    actual_case: dict[str, str],
    split_roots: dict[str, list[str]],
    self_variable: str | None = None,
) -> tuple[str, bool, str]:
    original = re.sub(r"\s+", " ", raw or "").strip()
    if not original:
        return "1", True, ""
    if any(token in original for token in ("$", "DateTime", "?", ";", "{")):
        return "1", False, original

    expression = original

    def actual(variable: str) -> str:
        return actual_case.get(variable.lower(), variable)

    def replace_inlist(match: re.Match[str]) -> str:
        variable = actual(match.group(1))
        codes = [
            value.strip()
            for value in match.group(2).split(",")
            if re.fullmatch(r"\s*-?\d+(?:\.\d+)?\s*", value)
        ]
        if not codes:
            return match.group(0)
        return inlist_expression(variable, codes)

    def replace_inrange(match: re.Match[str]) -> str:
        return f"inrange({actual(match.group(1))}, {match.group(2).strip()}, {match.group(3).strip()})"

    def replace_contains(match: re.Match[str]) -> str:
        root = match.group(1)
        code = match.group(2).strip()
        split = next(
            (
                variable
                for variable in split_roots.get(root.lower(), [])
                if variable.lower() == f"{root.lower()}__{code.lower()}"
            ),
            None,
        )
        return f"({split} == 1)" if split else match.group(0)

    expression = re.sub(
        r"([A-Za-z][A-Za-z0-9_]*)\.InList\(([^)]*)\)",
        replace_inlist,
        expression,
    )
    expression = re.sub(
        r"([A-Za-z][A-Za-z0-9_]*)\.InRange\(([^,]+),([^)]+)\)",
        replace_inrange,
        expression,
    )
    expression = re.sub(
        r"([A-Za-z][A-Za-z0-9_]*)\.Contains\(([^)]*)\)",
        replace_contains,
        expression,
    )

    if self_variable:
        root = self_variable

        def replace_self_contains(match: re.Match[str]) -> str:
            code = match.group(1).strip()
            split = next(
                (
                    variable
                    for variable in split_roots.get(root.lower(), [])
                    if variable.lower() == f"{root.lower()}__{code.lower()}"
                ),
                None,
            )
            return f"({split} == 1)" if split else match.group(0)

        expression = re.sub(
            r"self\.Contains\(([^)]*)\)", replace_self_contains, expression
        )
        split = split_roots.get(root.lower(), [])
        if split:
            expression = expression.replace("self.Count()", f"({' + '.join(split)})")
        expression = re.sub(r"\bself\b", actual(self_variable), expression)

    expression = re.sub(
        r"\b([A-Za-z][A-Za-z0-9_]*)\.HasValue\b",
        lambda match: f"!missing({actual(match.group(1))})",
        expression,
    )
    expression = re.sub(
        r"\b([A-Za-z][A-Za-z0-9_]*)\s*!=\s*null\b",
        lambda match: f"!missing({actual(match.group(1))})",
        expression,
        flags=re.IGNORECASE,
    )
    expression = re.sub(
        r"\b([A-Za-z][A-Za-z0-9_]*)\s*==\s*null\b",
        lambda match: f"missing({actual(match.group(1))})",
        expression,
        flags=re.IGNORECASE,
    )
    expression = expression.replace("&&", " & ").replace("||", " | ")
    expression = re.sub(r"\btrue\b", "1", expression, flags=re.IGNORECASE)
    expression = re.sub(r"\bfalse\b", "0", expression, flags=re.IGNORECASE)

    def actualize_token(match: re.Match[str]) -> str:
        token = match.group(0)
        return actual_case.get(token.lower(), token)

    expression = re.sub(r"\b[A-Za-z][A-Za-z0-9_]*\b", actualize_token, expression)
    expression = guard_nullable_comparisons(expression, actual_case)
    expression = re.sub(r"\s+", " ", expression).strip()

    if re.search(r"\.[A-Za-z]|\bnull\b|\?|\$|\[|\]", expression):
        return "1", False, original

    references = {
        token
        for token in re.findall(r"\b[A-Za-z][A-Za-z0-9_]*\b", expression)
        if token.lower() not in RESERVED
    }
    known_actual = set(actual_case.values())
    unknown = references - known_actual
    if unknown:
        return "1", False, original
    return expression, True, original


def export_block(
    condition: str,
    report_path: str,
    columns: list[str],
    message: str,
    source: str,
    action: str,
) -> list[str]:
    if source == "questionnaire":
        source = "questionnaire+hypothese_apurement"
    export_columns = list(dict.fromkeys(columns + ["commentaire", "source_regle", "action_proposee"]))
    return [
        f"count if {condition}",
        "if r(N)>0 {",
        f"    replace commentaire = {stata_quote(message)} if {condition}",
        f"    replace source_regle = {stata_quote(source, 60)} if {condition}",
        f"    replace action_proposee = {stata_quote(action, 60)} if {condition}",
        f"    export excel {' '.join(export_columns)} ///",
        f'        using "{report_path}", ///',
        f"        if {condition}, firstrow(variables) replace",
        '    replace commentaire = ""',
        '    replace source_regle = ""',
        '    replace action_proposee = ""',
        "}",
    ]


def matrix_row(
    row: dict[str, str],
    rule_id: str,
    data_variables: list[str],
    check_type: str,
    condition_stata: str,
    condition_status: str,
    expression_stata: str,
    decision_status: str,
    action: str,
    script: str,
) -> dict[str, str]:
    return {
        "rule_id": rule_id,
        "section_code": row["section_code"],
        "section": row["section"],
        "variable": row["variable"],
        "data_variables": "|".join(data_variables),
        "check_type": check_type,
        "condition_questionnaire": row["condition_effective"],
        "condition_stata": condition_stata,
        "condition_status": condition_status,
        "rule_expression_stata": expression_stata,
        "source_regle": row["source_regle"],
        "scope_stata": "$audit_scope",
        "scope_source": "hypothese_apurement",
        "scope_status": "a_valider",
        "decision_status": decision_status,
        "action": action,
        "script": script,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", required=True)
    args = parser.parse_args()

    project_root = Path(args.project_root).resolve()
    generated_root = project_root / "generated"
    program_generated = project_root / "program" / "generated"
    dictionary_path = generated_root / "dictionnaire_variables.csv"
    questionnaire_path = generated_root / "questionnaire_rules.csv"
    metier_path = project_root / "config" / "regles_metier_coso.csv"

    dictionary_rows = read_csv(dictionary_path)
    questionnaire_rows = read_csv(questionnaire_path)
    metier_rows = read_csv(metier_path) if metier_path.exists() else []
    by_lower, actual_case, split_roots = dictionary_maps(dictionary_rows)

    program_generated.mkdir(parents=True, exist_ok=True)
    for old_file in program_generated.glob("04_*.do"):
        old_file.unlink()

    context_columns = [
        variable
        for variable in ("interview__key", "cover_district")
        if variable.lower() in actual_case
    ]
    context_columns = [actual_case[item.lower()] for item in context_columns]

    grouped: dict[tuple[int, str, str], list[dict[str, str]]] = defaultdict(list)
    for row in questionnaire_rows:
        grouped[(int(row["section_order"]), row["section_code"], row["section"])].append(row)

    all_matrix_rows: list[dict[str, str]] = []
    scripts: list[str] = []
    translated_count = 0
    review_count = 0

    for (section_order, code, section), rows in sorted(grouped.items()):
        slug = safe_part(section)
        script_name = f"04_{section_order:02d}_{code}_{slug}.do"
        scripts.append(script_name)
        section_report = f'$document\\{section_order:02d}_{code}'
        section_output = f'$section_output\\{section_order:02d}_{code}.dta'
        lines = [
            "/*===========================================================================",
            f"  Section {ascii_text(section)}",
            "  Genere depuis le questionnaire Survey Solutions et le dictionnaire .dta.",
            "  Diagnostics uniquement : aucune correction automatique.",
            "  Perimetre provisoire : $audit_scope.",
            "===========================================================================*/",
            "",
            'use "$working_base", clear',
            "",
            "cap drop commentaire",
            'gen str244 commentaire = ""',
            "cap drop source_regle",
            'gen str60 source_regle = ""',
            "cap drop action_proposee",
            'gen str60 action_proposee = ""',
            "",
            f'cap mkdir "{section_report}"',
            "",
        ]
        section_variables: list[str] = []

        for row in rows:
            variable = row["variable"]
            lower = variable.lower()
            exact_meta = by_lower.get(lower)
            split_variables = split_roots.get(lower, [])
            matched = [exact_meta["variable"]] if exact_meta else split_variables
            section_variables.extend(matched)
            base_rule = f"Q_{code}_{safe_part(variable, 35)}"
            qtype = row["questionnaire_type"].lower()

            lines.extend(
                [
                    "*---------------------------------------------------------------------------",
                    f"* {ascii_text(variable)} - {ascii_text(row['question_text'])[:180]}",
                    f"* Type questionnaire : {ascii_text(qtype)}",
                ]
            )

            if qtype == "variable":
                all_matrix_rows.append(
                    matrix_row(
                        row,
                        f"{base_rule}_COMPUTED",
                        matched,
                        "variable_calculee",
                        "",
                        "non_applicable",
                        "",
                        "documente_questionnaire",
                        "documenter_sans_corriger",
                        script_name,
                    )
                )
                lines.append("* Variable calculee : documentee, sans controle automatique.")
                lines.append("")
                continue

            if not matched:
                review_count += 1
                all_matrix_rows.append(
                    matrix_row(
                        row,
                        f"{base_rule}_ABSENT",
                        [],
                        "presence_donnees",
                        "",
                        "A_VALIDER",
                        "",
                        "a_valider",
                        "verifier_correspondance_questionnaire_donnees",
                        script_name,
                    )
                )
                lines.append("* A_VALIDER : variable absente du dictionnaire de donnees.")
                lines.append("")
                continue

            if exact_meta and exact_meta.get("control_excluded", "").lower() == "true":
                all_matrix_rows.append(
                    matrix_row(
                        row,
                        f"{base_rule}_PII",
                        matched,
                        "confidentialite",
                        "",
                        "PII_EXCLUDED",
                        "",
                        "restriction_confidentialite",
                        "ne_pas_exporter",
                        script_name,
                    )
                )
                lines.append("* Variable sensible exclue des rapports automatiques.")
                lines.append("")
                continue

            universe, universe_ok, _ = translate_expression(
                row["condition_effective"], actual_case, split_roots
            )
            universe_status = "translated" if universe_ok else "A_VALIDER"

            export_vars = context_columns + [
                item
                for item in matched
                if by_lower[item.lower()].get("pii_restricted", "").lower() != "true"
            ]
            report_prefix = f"{section_report}\\{safe_part(variable, 45)}"
            audit_scope = "$audit_scope"

            if exact_meta:
                actual_variable = exact_meta["variable"]
                missing = missing_expression(actual_variable, exact_meta)
                answered = answered_expression(actual_variable, exact_meta)
                if universe_ok:
                    condition = f"({missing}) & ({universe}) & ({audit_scope})"
                    lines.extend(
                        export_block(
                            condition,
                            f"{report_prefix}_manquant.xlsx",
                            export_vars,
                            f"{variable} manquant dans son univers",
                            "questionnaire",
                            "revue_manuelle",
                        )
                    )
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_MISSING",
                            matched,
                            "manquant_univers",
                            universe,
                            universe_status,
                            condition,
                            "documente_questionnaire",
                            "export_excel_diagnostic",
                            script_name,
                        )
                    )
                    translated_count += 1
                    if row["condition_effective"]:
                        outside = f"({answered}) & !({universe}) & ({audit_scope})"
                        lines.extend(
                            export_block(
                                outside,
                                f"{report_prefix}_hors_univers.xlsx",
                                export_vars,
                                f"{variable} renseigne hors univers",
                                "questionnaire",
                                "vider_apres_validation",
                            )
                        )
                        all_matrix_rows.append(
                            matrix_row(
                                row,
                                f"{base_rule}_SKIP",
                                matched,
                                "saut_univers",
                                universe,
                                universe_status,
                                outside,
                                "documente_questionnaire",
                                "export_excel_diagnostic",
                                script_name,
                            )
                        )
                        translated_count += 1
                else:
                    review_count += 1
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_UNIVERSE_REVIEW",
                            matched,
                            "univers",
                            "",
                            "A_VALIDER",
                            "",
                            "a_valider",
                            "traduire_condition_questionnaire",
                            script_name,
                        )
                    )
                    lines.append(
                        f"* A_VALIDER univers : {ascii_text(row['condition_effective'])}"
                    )

                options = parse_options(row["options"])
                codes = [code_value for code_value, _ in options]
                if qtype == "single-select" and codes:
                    allowed = inlist_expression(actual_variable, codes)
                    domain = f"!({allowed}) & ({answered}) & ({audit_scope})"
                    lines.extend(
                        export_block(
                            domain,
                            f"{report_prefix}_hors_domaine.xlsx",
                            export_vars,
                            f"{variable} hors domaine questionnaire",
                            "questionnaire",
                            "revue_manuelle",
                        )
                    )
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_DOMAIN",
                            matched,
                            "domaine",
                            universe if universe_ok else "",
                            universe_status,
                            domain,
                            "documente_questionnaire",
                            "export_excel_diagnostic",
                            script_name,
                        )
                    )
                    translated_count += 1
                elif qtype == "single-select: cascading":
                    review_count += 1
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_CASCADE_HIERARCHY_REVIEW",
                            matched,
                            "coherence_hierarchie_cascade",
                            universe if universe_ok else "",
                            "A_VALIDER",
                            "",
                            "a_valider",
                            "verifier_domaine_et_hierarchie_cascade",
                            script_name,
                        )
                    )
                    lines.append(
                        "* A_VALIDER : domaine et coherence parent-enfant de la "
                        "cascade; les options du HTML Preview peuvent etre tronquees."
                    )
                elif qtype.startswith("numeric") and codes:
                    special = f"{inlist_expression(actual_variable, codes)} & ({answered}) & ({audit_scope})"
                    lines.extend(
                        export_block(
                            special,
                            f"{report_prefix}_code_special.xlsx",
                            export_vars,
                            f"{variable} contient un code special autorise",
                            "questionnaire",
                            "recodage_analyse_a_valider",
                        )
                    )
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_SPECIAL",
                            matched,
                            "code_special_autorise",
                            universe if universe_ok else "",
                            universe_status,
                            special,
                            "documente_questionnaire_action_a_valider",
                            "export_excel_diagnostic",
                            script_name,
                        )
                    )
                    translated_count += 1

                validations = [
                    item.strip()
                    for item in row["validation_questionnaire"].split("|||")
                    if item.strip()
                ]
                for index, validation_raw in enumerate(validations, start=1):
                    validation, validation_ok, _ = translate_expression(
                        validation_raw,
                        actual_case,
                        split_roots,
                        self_variable=actual_variable,
                    )
                    if validation_ok and universe_ok:
                        invalid = f"({answered}) & ({universe}) & !({validation}) & ({audit_scope})"
                        lines.extend(
                            export_block(
                                invalid,
                                f"{report_prefix}_validation_{index}.xlsx",
                                export_vars,
                                f"{variable} viole la validation questionnaire {index}",
                                "questionnaire",
                                "revue_manuelle",
                            )
                        )
                        all_matrix_rows.append(
                            matrix_row(
                                row,
                                f"{base_rule}_VALIDATION_{index}",
                                matched,
                                "validation",
                                universe,
                                "translated",
                                invalid,
                                "documente_questionnaire",
                                "export_excel_diagnostic",
                                script_name,
                            )
                        )
                        translated_count += 1
                    else:
                        review_count += 1
                        all_matrix_rows.append(
                            matrix_row(
                                row,
                                f"{base_rule}_VALIDATION_{index}_REVIEW",
                                matched,
                                "validation",
                                universe if universe_ok else "",
                                "A_VALIDER",
                                "",
                                "a_valider",
                                "traduire_validation_questionnaire",
                                script_name,
                            )
                        )
                        lines.append(
                            f"* A_VALIDER validation : {ascii_text(validation_raw)}"
                        )

            else:
                all_missing = " & ".join(f"missing({item})" for item in split_variables)
                any_answered = " | ".join(f"!missing({item})" for item in split_variables)
                if universe_ok:
                    missing = f"({all_missing}) & ({universe}) & ({audit_scope})"
                    lines.extend(
                        export_block(
                            missing,
                            f"{report_prefix}_manquant.xlsx",
                            export_vars,
                            f"{variable} multi-select manquant dans son univers",
                            "questionnaire",
                            "revue_manuelle",
                        )
                    )
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_MISSING",
                            split_variables,
                            "manquant_univers_multiselect",
                            universe,
                            "translated",
                            missing,
                            "documente_questionnaire",
                            "export_excel_diagnostic",
                            script_name,
                        )
                    )
                    translated_count += 1
                    if row["condition_effective"]:
                        outside = f"({any_answered}) & !({universe}) & ({audit_scope})"
                        lines.extend(
                            export_block(
                                outside,
                                f"{report_prefix}_hors_univers.xlsx",
                                export_vars,
                                f"{variable} multi-select renseigne hors univers",
                                "questionnaire",
                                "vider_apres_validation",
                            )
                        )
                        all_matrix_rows.append(
                            matrix_row(
                                row,
                                f"{base_rule}_SKIP",
                                split_variables,
                                "saut_univers_multiselect",
                                universe,
                                "translated",
                                outside,
                                "documente_questionnaire",
                                "export_excel_diagnostic",
                                script_name,
                            )
                        )
                        translated_count += 1
                else:
                    review_count += 1
                    lines.append(
                        f"* A_VALIDER univers multi-select : {ascii_text(row['condition_effective'])}"
                    )

                for split_variable in split_variables:
                    domain = f"!inlist({split_variable}, 0, 1) & !missing({split_variable}) & ({audit_scope})"
                    lines.extend(
                        export_block(
                            domain,
                            f"{section_report}\\{safe_part(split_variable, 45)}_hors_domaine.xlsx",
                            context_columns + [split_variable],
                            f"{split_variable} hors domaine 0/1",
                            "questionnaire",
                            "revue_manuelle",
                        )
                    )
                    all_matrix_rows.append(
                        matrix_row(
                            row,
                            f"{base_rule}_DOMAIN_{safe_part(split_variable, 25)}",
                            [split_variable],
                            "domaine_multiselect",
                            universe if universe_ok else "",
                            universe_status,
                            domain,
                            "documente_questionnaire",
                            "export_excel_diagnostic",
                            script_name,
                        )
                    )
                    translated_count += 1

                validations = [
                    item.strip()
                    for item in row["validation_questionnaire"].split("|||")
                    if item.strip()
                ]
                for index, validation_raw in enumerate(validations, start=1):
                    validation, validation_ok, _ = translate_expression(
                        validation_raw,
                        actual_case,
                        split_roots,
                        self_variable=variable,
                    )
                    if validation_ok and universe_ok:
                        invalid = f"({any_answered}) & ({universe}) & !({validation}) & ({audit_scope})"
                        lines.extend(
                            export_block(
                                invalid,
                                f"{report_prefix}_validation_{index}.xlsx",
                                export_vars,
                                f"{variable} viole la validation questionnaire {index}",
                                "questionnaire",
                                "revue_manuelle",
                            )
                        )
                        all_matrix_rows.append(
                            matrix_row(
                                row,
                                f"{base_rule}_VALIDATION_{index}",
                                split_variables,
                                "validation_multiselect",
                                universe,
                                "translated",
                                invalid,
                                "documente_questionnaire",
                                "export_excel_diagnostic",
                                script_name,
                            )
                        )
                        translated_count += 1
                    else:
                        review_count += 1
                        all_matrix_rows.append(
                            matrix_row(
                                row,
                                f"{base_rule}_VALIDATION_{index}_REVIEW",
                                split_variables,
                                "validation_multiselect",
                                universe if universe_ok else "",
                                "A_VALIDER",
                                "",
                                "a_valider",
                                "traduire_validation_questionnaire",
                                script_name,
                            )
                        )
                        lines.append(
                            f"* A_VALIDER validation multi-select : {ascii_text(validation_raw)}"
                        )

            lines.append("")

        output_keep = list(dict.fromkeys(context_columns + section_variables))
        lines.extend(
            [
                "preserve",
                "    keep if $audit_scope",
                f"    keep {' '.join(output_keep)}",
                "    capture isid interview__key",
                "    if _rc {",
                f'        display as error "Cle interview__key non unique dans la vue {code}."',
                "        exit 459",
                "    }",
                f'    save "{section_output}", replace',
                "restore",
                "",
                f'display as result "Controles section {code} termines."',
            ]
        )
        (program_generated / script_name).write_text(
            "\n".join(lines) + "\n", encoding="utf-8"
        )

    include_lines = [
        "/* Liste generee des controles questionnaire. */",
        "",
    ] + [f'do "$generated_dofiles\\{script}"' for script in scripts]
    (program_generated / "00_generated_sections.do").write_text(
        "\n".join(include_lines) + "\n", encoding="utf-8"
    )

    for metier in metier_rows:
        all_matrix_rows.append(
            {
                "rule_id": metier["rule_id"],
                "section_code": metier["section"],
                "section": f"REGLE METIER SECTION {metier['section']}",
                "variable": metier["variable"],
                "data_variables": metier["variable"],
                "check_type": metier["check_type"],
                "condition_questionnaire": "",
                "condition_stata": metier["condition_stata"],
                "condition_status": "executable_metier_propose",
                "rule_expression_stata": metier["condition_stata"],
                "source_regle": metier["source_regle"],
                "scope_stata": "$metier_scope",
                "scope_source": "hypothese_apurement",
                "scope_status": "a_valider",
                "decision_status": metier["decision_status"],
                "action": metier["action_proposee"],
                "script": "50_controles_metier_proposes.do",
            }
        )

    matrix_path = generated_root / "apurement_rule_matrix.csv"
    fieldnames = list(all_matrix_rows[0].keys())
    with matrix_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_matrix_rows)

    summary = [
        "# Synthese de generation du template COSO",
        "",
        f"- Sections : {len(scripts)}",
        f"- Objets du questionnaire : {len(questionnaire_rows)}",
        f"- Regles matricielles : {len(all_matrix_rows)}",
        f"- Controles questionnaire traduits/executables : {translated_count}",
        f"- Elements questionnaire a valider ou traduire : {review_count}",
        f"- Regles metier proposees executables mais a valider : {len(metier_rows)}",
        f"- Scripts R generes par section : {len(scripts)}",
        "- Corrections automatiques generees : 0",
        "",
        "Les univers incluent les conditions heritees des sections et groupes.",
        "Les codes speciaux sont exportes separement et ne sont pas classes comme",
        "valeurs illegales lorsqu'ils sont autorises par le questionnaire.",
    ]
    (generated_root / "GENERATION_SUMMARY.md").write_text(
        "\n".join(summary) + "\n", encoding="utf-8"
    )

    print(f"Do-files generes : {len(scripts)}")
    print(f"Regles matricielles : {len(all_matrix_rows)}")
    print(f"Controles questionnaire executables : {translated_count}")
    print(f"Elements questionnaire A_VALIDER : {review_count}")
    print(f"Regles metier proposees a valider : {len(metier_rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

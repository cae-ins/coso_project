"""Extract Survey Solutions questionnaire metadata from the COSO export.

The extractor keeps local and inherited activation conditions separate.  The
effective universe combines section, group/roster and question conditions.
No business rule is inferred here.
"""

from __future__ import annotations

import csv
import re
import sys
from collections import Counter
from pathlib import Path
from zipfile import ZipFile

from bs4 import BeautifulSoup, Tag


RESTRICTED_OPTION_LABEL_VARIABLES = {"nom_agent", "nom_sup"}


def compact(value: str) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def text_without_marker(node: Tag | None) -> str:
    if node is None:
        return ""
    clone = BeautifulSoup(str(node), "html.parser")
    root = clone.find()
    if root is None:
        return ""
    for marker in root.find_all("span", recursive=False):
        marker.decompose()
    return compact(root.get_text(" ", strip=True))


def direct_child(parent: Tag | None, tag: str, class_name: str) -> Tag | None:
    if parent is None:
        return None
    return parent.find(tag, class_=class_name, recursive=False)


def condition_from_common(container: Tag | None) -> str:
    common = direct_child(container, "div", "common-info")
    condition = direct_child(common, "div", "condition")
    return text_without_marker(condition)


def section_condition(section: Tag) -> str:
    header = direct_child(section, "div", "section_header")
    return condition_from_common(header)


def ancestor_condition(ancestor: Tag) -> str:
    classes = set(ancestor.get("class", []))
    if "group" in classes:
        return condition_from_common(direct_child(ancestor, "div", "group_container"))
    if "roster" in classes:
        return condition_from_common(direct_child(ancestor, "div", "roster_container"))
    return ""


def local_condition(question: Tag) -> str:
    question_side = direct_child(question, "div", "question")
    return condition_from_common(question_side)


def effective_condition(question: Tag, section: Tag) -> tuple[str, str, str]:
    inherited: list[str] = []
    sec_condition = section_condition(section)
    if sec_condition:
        inherited.append(sec_condition)

    ancestors = [
        node
        for node in question.parents
        if isinstance(node, Tag)
        and ({"group", "roster"} & set(node.get("class", [])))
    ]
    for ancestor in reversed(ancestors):
        value = ancestor_condition(ancestor)
        if value and value not in inherited:
            inherited.append(value)

    local = local_condition(question)
    parts = inherited + ([local] if local else [])
    effective = " && ".join(f"({part})" for part in parts)
    return " && ".join(inherited), local, effective


def read_questionnaire(path: Path) -> tuple[bytes, str]:
    if path.suffix.lower() in {".html", ".htm"}:
        return path.read_bytes(), path.name

    if path.suffix.lower() != ".zip":
        raise ValueError(f"Format questionnaire non pris en charge : {path.suffix}")

    with ZipFile(path) as archive:
        names = archive.namelist()
        exact = [
            name
            for name in names
            if Path(name).name.lower() == "original questionnaire_coso_v5.html"
        ]
        candidates = exact or [
            name
            for name in names
            if name.lower().endswith((".html", ".htm"))
            and "questionnaire" in name.lower()
        ]
        if len(candidates) != 1:
            raise ValueError(
                "Impossible d'identifier sans ambiguite le questionnaire HTML "
                f"dans {path}. Candidats : {candidates}"
            )
        return archive.read(candidates[0]), f"{path.name}!{candidates[0]}"


def section_title(section: Tag) -> str:
    header = direct_child(section, "div", "section_header")
    if header is None:
        return "[section_sans_nom]"
    heading = header.find(["h2", "h3"], recursive=False)
    if heading is not None:
        return compact(heading.get_text(" ", strip=True))
    sub = header.find(class_="sub_section")
    if sub is not None:
        return compact(sub.get_text(" ", strip=True))
    return compact(header.get_text(" ", strip=True)).split(" Questions:", 1)[0]


def section_code(title: str, order: int) -> str:
    if title.lower().startswith("couverture"):
        return "COVER"
    match = re.match(r"\s*([A-R])(?:\.|\s)", title, flags=re.IGNORECASE)
    return match.group(1).upper() if match else f"S{order:02d}"


def extract_rows(html: bytes, source: str) -> list[dict[str, str]]:
    soup = BeautifulSoup(html, "html.parser")
    rows: list[dict[str, str]] = []

    for section_order, section in enumerate(soup.select("section.section"), start=1):
        title = section_title(section)
        code = section_code(title, section_order)

        for question_order, question in enumerate(
            section.select(".question-container"), start=1
        ):
            variable_node = question.select_one(".variable_name")
            if variable_node is None:
                continue
            variable = compact(variable_node.get_text(" ", strip=True))

            question_side = direct_child(question, "div", "question")
            title_node = direct_child(question_side, "div", "question-title")
            variable_expression_node = question.select_one(".variable-expression")
            variable_expression = compact(
                variable_expression_node.get_text(" ", strip=True)
                if variable_expression_node
                else ""
            )

            answer = direct_child(question, "div", "answer")
            type_node = answer.select_one(".question-meta .type") if answer else None
            questionnaire_type = compact(
                type_node.get_text(" ", strip=True) if type_node else ""
            ).lower()
            if variable_expression:
                questionnaire_type = "variable"

            inherited, local, effective = effective_condition(question, section)

            validations = [
                text_without_marker(node)
                for node in question.select(
                    ":scope > .question > .common-info > .validation-expression"
                )
            ]
            validation_messages = [
                text_without_marker(node)
                for node in question.select(
                    ":scope > .question > .common-info > .validation-message"
                )
            ]

            options: list[str] = []
            if answer is not None:
                for option in answer.select(".option"):
                    value_node = option.select_one(".option-value")
                    label_node = option.select_one(
                        ".option-text, .yes_no-option-text"
                    )
                    if value_node is None:
                        continue
                    value = compact(value_node.get_text(" ", strip=True))
                    label = compact(
                        label_node.get_text(" ", strip=True) if label_node else ""
                    )
                    if variable.lower() in RESTRICTED_OPTION_LABEL_VARIABLES:
                        label = "[REDACTED]"
                    options.append(f"{value}:{label}")

            rows.append(
                {
                    "section_order": str(section_order),
                    "section_code": code,
                    "section": title,
                    "question_order": str(question_order),
                    "variable": variable,
                    "questionnaire_type": questionnaire_type,
                    "question_text": text_without_marker(title_node),
                    "condition_inherited": inherited,
                    "condition_local": local,
                    "condition_effective": effective,
                    "validation_questionnaire": " ||| ".join(
                        value for value in validations if value
                    ),
                    "validation_message": " ||| ".join(
                        value for value in validation_messages if value
                    ),
                    "variable_expression": variable_expression,
                    "options": "|".join(options),
                    "source_regle": "questionnaire",
                    "source_document": source,
                }
            )

    return rows


def write_csv(path: Path, rows: list[dict[str, str]], fields: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    if len(sys.argv) < 4:
        print(
            "Usage: 03_extract_questionnaire_rules.py input.zip|questionnaire.html "
            "questionnaire_rules.csv sections_questionnaire.csv",
            file=sys.stderr,
        )
        return 2

    source_path = Path(sys.argv[1]).resolve()
    rules_path = Path(sys.argv[2]).resolve()
    sections_path = Path(sys.argv[3]).resolve()

    html, source = read_questionnaire(source_path)
    rows = extract_rows(html, source)
    if not rows:
        raise RuntimeError("Aucune question extraite du questionnaire.")

    fields = list(rows[0].keys())
    write_csv(rules_path, rows, fields)

    counts = Counter((row["section_order"], row["section_code"], row["section"]) for row in rows)
    section_rows = [
        {
            "section_order": key[0],
            "section_code": key[1],
            "section": key[2],
            "n_questionnaire_objects": str(count),
        }
        for key, count in sorted(counts.items(), key=lambda item: int(item[0][0]))
    ]
    write_csv(
        sections_path,
        section_rows,
        ["section_order", "section_code", "section", "n_questionnaire_objects"],
    )

    print(f"Regles questionnaire : {len(rows)} objets dans {len(section_rows)} sections")
    print(f"Sortie : {rules_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

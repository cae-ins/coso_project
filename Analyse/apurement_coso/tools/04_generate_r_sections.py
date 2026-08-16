"""Generate one auditable R wrapper per COSO questionnaire section."""

from __future__ import annotations

import argparse
import csv
import re
import unicodedata
from pathlib import Path


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return [dict(row) for row in csv.DictReader(handle)]


def safe_part(value: str, max_length: int = 55) -> str:
    normalized = unicodedata.normalize("NFKD", value or "")
    ascii_value = normalized.encode("ascii", "ignore").decode("ascii")
    output = re.sub(r"[^A-Za-z0-9_]+", "_", ascii_value).strip("_")
    return (output or "section")[:max_length]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", required=True)
    args = parser.parse_args()

    project_root = Path(args.project_root).resolve()
    sections = read_csv(project_root / "generated" / "sections_questionnaire.csv")
    output_root = project_root / "R" / "generated"
    output_root.mkdir(parents=True, exist_ok=True)
    for old_file in output_root.glob("04_*.R"):
        old_file.unlink()

    scripts: list[str] = []
    for row in sections:
        order = int(row["section_order"])
        code = row["section_code"]
        script_name = f"04_{order:02d}_{code}_{safe_part(row['section'])}.R"
        scripts.append(script_name)
        content = [
            "# Fichier genere : ne pas modifier manuellement.",
            f"# Section {row['section']}",
            "section_manifest <- run_section_rules(",
            "  data = state$data,",
            "  matrix = state$matrix,",
            "  ctx = state$ctx,",
            f'  section_code = "{code}",',
            f"  section_order = {order}L",
            ")",
            "state$manifest <- append_rows(state$manifest, section_manifest)",
            "rm(section_manifest)",
            "",
        ]
        (output_root / script_name).write_text("\n".join(content), encoding="utf-8")

    include = [
        "# Liste generee des scripts R de controles questionnaire.",
        "generated_section_scripts <- c(",
    ]
    for index, script in enumerate(scripts):
        comma = "," if index < len(scripts) - 1 else ""
        include.append(f'  "{script}"{comma}')
    include.extend([")", ""])
    (output_root / "00_generated_sections.R").write_text(
        "\n".join(include), encoding="utf-8"
    )

    print(f"Scripts R generes : {len(scripts)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

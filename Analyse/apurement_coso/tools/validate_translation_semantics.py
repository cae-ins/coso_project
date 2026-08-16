"""Regression checks for Survey Solutions to Stata expression translation."""

from __future__ import annotations

import argparse
import importlib.util
from pathlib import Path


def load_generator(path: Path):
    spec = importlib.util.spec_from_file_location("coso_stata_generator", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Impossible de charger {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", required=True)
    args = parser.parse_args()
    root = Path(args.project_root).resolve()
    generator = load_generator(root / "tools" / "04_generate_stata_sections.py")

    actual = {"c4": "C4", "d1": "D1", "d2": "D2"}
    split: dict[str, list[str]] = {}
    cases = {
        "C4>=2": ("!missing(C4)", "C4 >= 2"),
        "D2<D1": ("!missing(D2)", "!missing(D1)", "D2 < D1"),
        "C4==1 || C4!=2": ("!missing(C4)", "C4 == 1", "C4 != 2"),
    }
    for raw, expected_parts in cases.items():
        translated, ok, _ = generator.translate_expression(raw, actual, split)
        if not ok:
            raise SystemExit(f"Traduction refusee pour {raw}: {translated}")
        missing = [part for part in expected_parts if part not in translated]
        if missing:
            raise SystemExit(
                f"Gardes nullable absentes pour {raw}: {missing}; obtenu {translated}"
            )

    translated_null, ok_null, _ = generator.translate_expression(
        "C4!=null", actual, split
    )
    if not ok_null or translated_null != "!missing(C4)":
        raise SystemExit(
            "La traduction de null a regresse : " + translated_null
        )

    print("Nullable comparison translation validation: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

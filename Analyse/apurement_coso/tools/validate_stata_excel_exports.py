"""Reject filtered Stata Excel exports without an r(N)>0 guard."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


EXPORT_RE = re.compile(r"^\s*export\s+excel\b.*\sif\s", re.IGNORECASE)
GUARD_RE = re.compile(r"^if\s+r\(N\)\s*>\s*0\s*\{$", re.IGNORECASE)


def active_commands(path: Path) -> list[tuple[int, str]]:
    commands: list[tuple[int, str]] = []
    fragments: list[str] = []
    start_line = 0
    in_block_comment = False

    for line_number, line in enumerate(
        path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1
    ):
        stripped = line.lstrip()
        if in_block_comment:
            if "*/" in line:
                in_block_comment = False
            continue
        if stripped.startswith("/*"):
            if "*/" not in stripped:
                in_block_comment = True
            continue
        if not stripped or stripped.startswith("*") or stripped.startswith("//"):
            continue

        if not fragments:
            start_line = line_number
        continued = line.rstrip().endswith("///")
        fragments.append(line.rstrip()[:-3] if continued else line)
        if not continued:
            commands.append((start_line, " ".join(fragments)))
            fragments = []
    return commands


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", required=True)
    args = parser.parse_args()
    program_root = Path(args.project_root).resolve() / "program"

    issues: list[str] = []
    for path in sorted(program_root.rglob("*.do")):
        brace_level = 0
        guard_levels: list[int] = []
        for line_number, command in active_commands(path):
            stripped = command.strip()
            if GUARD_RE.fullmatch(stripped):
                brace_level += command.count("{") - command.count("}")
                guard_levels.append(brace_level)
                continue

            if EXPORT_RE.match(command) and not guard_levels:
                issues.append(f"{path.relative_to(program_root)}:{line_number}: {command}")

            brace_level += command.count("{") - command.count("}")
            guard_levels = [level for level in guard_levels if level <= brace_level]

    if issues:
        print("Exports Excel conditionnels sans garde count/if r(N)>0 :")
        print("\n".join(issues))
        return 1

    print("Stata conditional Excel-export guard validation: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

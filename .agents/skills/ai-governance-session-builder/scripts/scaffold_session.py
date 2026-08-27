#!/usr/bin/env python3
"""Create a schema-version 2 guided co-implementation session kit."""

from __future__ import annotations

import argparse
import re
import shutil
from datetime import date
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATES_ROOT = SKILL_ROOT / "assets" / "templates"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--id", required=True, help="Numeric session ID, such as 01")
    parser.add_argument("--slug", required=True, help="Kebab-case session slug")
    parser.add_argument("--title", required=True)
    parser.add_argument("--duration-minutes", type=int, default=180)
    return parser.parse_args()


def validate_args(args: argparse.Namespace) -> tuple[str, str]:
    try:
        session_id = f"{int(args.id):02d}"
    except ValueError as error:
        raise SystemExit("--id must be numeric") from error

    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", args.slug):
        raise SystemExit("--slug must be lower-case kebab-case")
    if not args.title.strip():
        raise SystemExit("--title cannot be empty")
    if not 30 <= args.duration_minutes <= 480:
        raise SystemExit("--duration-minutes must be between 30 and 480")
    return session_id, args.slug


def copy_templates(target: Path, replacements: dict[str, str]) -> None:
    for source in TEMPLATES_ROOT.rglob("*"):
        relative = source.relative_to(TEMPLATES_ROOT)
        destination = target / relative
        if source.is_dir():
            continue

        destination.parent.mkdir(parents=True, exist_ok=True)
        text = source.read_text(encoding="utf-8")
        for placeholder, value in replacements.items():
            text = text.replace(placeholder, value)
        destination.write_text(text, encoding="utf-8", newline="\n")


def copy_assets(target: Path) -> None:
    asset_mappings = [
        (SKILL_ROOT / "assets" / "marp", target / "assets" / "theme"),
        (SKILL_ROOT / "assets" / "logos", target / "assets" / "logos"),
        (
            SKILL_ROOT / "assets" / "microsoft-icons",
            target / "assets" / "icons" / "microsoft",
        ),
    ]
    for source, destination in asset_mappings:
        if not source.is_dir():
            raise SystemExit(f"Bundled asset directory is missing: {source}")
        shutil.copytree(source, destination, dirs_exist_ok=True)


def main() -> int:
    args = parse_args()
    session_id, slug = validate_args(args)
    repo_root = args.repo_root.resolve()
    target = repo_root / "sessions" / f"{session_id}-{slug}"

    if target.exists():
        raise SystemExit(f"Refusing to overwrite existing session: {target}")

    replacements = {
        "{{SESSION_ID}}": session_id,
        "{{SESSION_SLUG}}": slug,
        "{{SESSION_TITLE}}": args.title.strip(),
        "{{DURATION_MINUTES}}": str(args.duration_minutes),
        "{{CURRENT_DATE}}": date.today().isoformat(),
    }

    target.mkdir(parents=True)
    try:
        copy_templates(target, replacements)
        copy_assets(target)
    except Exception:
        shutil.rmtree(target, ignore_errors=True)
        raise

    print(f"Created session kit: {target}")
    print("Complete session.yaml first, then the implementation document, artifacts, and deck.")
    print("PowerShell and Bash preflight scripts must block every __REQUIRED_*__ decision sentinel.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

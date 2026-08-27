#!/usr/bin/env python3
"""Validate a schema-version 2 guided co-implementation session or optional module kit."""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import tempfile
from datetime import date
from pathlib import Path, PurePosixPath
from urllib.parse import urlsplit, urlunsplit


REQUIRED_FILES = [
    ".gitignore",
    "deck.md",
    "assets/theme/ai-governance.css",
    "assets/diagrams/README.md",
    "assets/icons/microsoft/README.md",
    "assets/logos/logo-full.png",
    "assets/logos/logo-full-white.png",
    "assets/logos/logo-mark.png",
    "assets/logos/logo-mark-white.png",
    "implementation/README.md",
    "implementation/artifacts/README.md",
    "implementation/scripts/preflight.ps1",
    "implementation/scripts/preflight.sh",
]
FORBIDDEN_PATHS = {
    "implementation-guide.md",
    "implementation/scripts/cleanup-test-fixtures.ps1",
    "implementation/scripts/cleanup-test-fixtures.sh",
}
FORBIDDEN_FIXTURE_PARTS = {"fixture", "fixtures", "test-fixture", "test-fixtures"}
FORBIDDEN_PACKAGE_DIRS = {"evidence", "proof", "proofs"}
LEGACY_NAMES = {"lab", "starter", "solution", "material.md"}
OBSOLETE_MANIFEST_KEYS = {
    "acceptance_criteria",
    "evidence_plan",
    "disposition",
    "cleanup_test_fixtures",
    "remove",
}
IMPLEMENTATION_HEADINGS = [
    "## Architecture",
    "## Before you start",
    "## Decisions and stop conditions",
    "## Implement",
    "## Confirm the result",
    "## After implementation",
]
OPTIONAL_IMPLEMENTATION_HEADINGS = {
    "## Field reference": "## Decisions and stop conditions",
}
SCOPE_SUBHEADINGS = [
    "### What we will do",
    "### Why it matters",
    "### Boundaries",
]
ARCHITECTURE_SUBHEADINGS = [
    "### Architecture at a glance",
    "### Design choices and tradeoffs",
    "### Architecture guidance",
]
PLACEHOLDER_PATTERN = re.compile(
    r"\bTODO\b|(?<!\$)\{\{[^}]+\}\}|learn\.microsoft\.com/TODO", re.IGNORECASE
)
SENTINEL_PATTERN = re.compile(r"__REQUIRED_[A-Z0-9_]+__")
BINARY_SUFFIXES = {
    ".gif",
    ".ico",
    ".jpeg",
    ".jpg",
    ".pdf",
    ".png",
    ".pyc",
    ".svg",
    ".webp",
}
GENERIC_RETAINED_METADATA = {
    "artifact",
    "consumer",
    "implementation output",
    "leave behind",
    "module output",
    "operational purpose",
    "output",
    "purpose",
    "repo",
    "repository",
    "implementation file",
    "operational control",
    "implementation file",
    "operational control",
    "session output",
}
RETAINED_TABLE_HEADING = "### Implementation files"
RETAINED_TABLE_COLUMNS = ("Type", "File", "Consumer")
IMPLEMENTATION_FILE_TYPES = ("Deployment", "Runtime", "Record")
RAW_HTML_VOID_TAGS = {
    "area",
    "base",
    "basefont",
    "br",
    "col",
    "embed",
    "frame",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "menuitem",
    "meta",
    "param",
    "source",
    "track",
    "wbr",
}
RAW_HTML_TAG_PATTERN = re.compile(
    r"<(?P<closing>/)?(?P<name>[A-Za-z][A-Za-z0-9:_-]*)"
    r"(?:\s+(?:[^<>'\"]|'[^']*'|\"[^\"]*\")*?)?"
    r"\s*(?P<self_closing>/)?>",
    re.IGNORECASE,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit_dir", type=Path)
    parser.add_argument("--render", action="store_true")
    return parser.parse_args()


def scalar(value: str):
    value = value.strip()
    if not value:
        return {}
    if value in {"[]", "{}"}:
        return [] if value == "[]" else {}
    if value.lower() in {"null", "~"}:
        return None
    if value.lower() in {"true", "false"}:
        return value.lower() == "true"
    if value.startswith(('"', "'")) and value.endswith(value[0]):
        return value[1:-1]
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    return value


def parse_yaml(text: str) -> dict:
    """Parse the contract's small YAML subset without a runtime dependency."""
    tokens = []
    for number, raw in enumerate(text.splitlines(), 1):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        if "\t" in raw[:indent]:
            raise ValueError(f"tabs are not allowed at line {number}")
        tokens.append((indent, raw.strip(), number))

    def block(index: int, indent: int):
        is_list = tokens[index][1].startswith("- ")
        result = [] if is_list else {}
        while index < len(tokens):
            current_indent, content, number = tokens[index]
            if current_indent < indent:
                break
            if current_indent != indent:
                raise ValueError(f"unexpected indentation at line {number}")
            if is_list:
                if not content.startswith("- "):
                    break
                item = content[2:].strip()
                if item.startswith(('"', "'")) and item.endswith(item[0]):
                    result.append(scalar(item))
                    index += 1
                    continue
                if ": " in item or item.endswith(":"):
                    key, value = item.split(":", 1)
                    mapping = {key: scalar(value)}
                    index += 1
                    if index < len(tokens) and tokens[index][0] > indent:
                        nested, index = block(index, tokens[index][0])
                        if value.strip():
                            if not isinstance(nested, dict):
                                raise ValueError(f"invalid list mapping at line {number}")
                            mapping.update(nested)
                        else:
                            mapping[key] = nested
                    result.append(mapping)
                    continue
                result.append(scalar(item))
                index += 1
            else:
                if content.startswith("- ") or ":" not in content:
                    break
                key, value = content.split(":", 1)
                index += 1
                if value.strip():
                    result[key] = scalar(value)
                elif index < len(tokens) and tokens[index][0] > indent:
                    result[key], index = block(index, tokens[index][0])
                else:
                    result[key] = {}
        return result, index

    if not tokens:
        return {}
    parsed, end = block(0, tokens[0][0])
    if end != len(tokens) or not isinstance(parsed, dict):
        raise ValueError("invalid YAML document")
    return parsed


def read_text(path: Path, failures: list[str]) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        failures.append(f"Cannot read {path}: {error}")
        return ""


def require_headings(
    text: str,
    headings: list[str],
    label: str,
    failures: list[str],
) -> None:
    positions = []
    for heading in headings:
        position = text.find(heading)
        if position < 0:
            failures.append(f"{label} is missing heading: {heading}")
        positions.append(position)
    present = [position for position in positions if position >= 0]
    if present != sorted(present):
        failures.append(f"{label} headings are not in the required order")


def require_implementation_chapters(
    text: str,
    scope_heading: str,
    failures: list[str],
) -> None:
    actual = [
        f"## {match.group(1).rstrip('#').strip()}"
        for match in re.finditer(r"(?m)^##\s+(.+?)\s*$", text)
    ]
    expected = [scope_heading, *IMPLEMENTATION_HEADINGS]
    for optional, after in OPTIONAL_IMPLEMENTATION_HEADINGS.items():
        if optional in actual:
            expected.insert(expected.index(after) + 1, optional)

    if actual != expected:
        failures.append(
            "implementation/README.md level-two headings must define the shared chapter "
            f"structure in this order: {', '.join(expected)}"
        )


def validate_scope_subsections(
    text: str,
    scope_heading: str,
    failures: list[str],
) -> None:
    start = re.search(rf"(?m)^{re.escape(scope_heading)}\s*$", text)
    if not start:
        return
    scope_lines: list[str] = []
    in_fence = False
    fence_marker = ""
    for line in text[start.end() :].splitlines(keepends=True):
        fence = re.match(r"^\s*(`{3,}|~{3,})", line)
        if fence:
            marker = fence.group(1)
            if not in_fence:
                in_fence = True
                fence_marker = marker[0]
            elif marker[0] == fence_marker:
                in_fence = False
                fence_marker = ""
            scope_lines.append(line)
            continue
        if not in_fence and re.match(r"^##(?:\s+|$)", line):
            break
        scope_lines.append(line)

    scope = "".join(scope_lines)
    heading_matches: list[tuple[str, int, int]] = []
    in_fence = False
    fence_marker = ""
    offset = 0
    for line in scope_lines:
        fence = re.match(r"^\s*(`{3,}|~{3,})", line)
        if fence:
            marker = fence.group(1)
            if not in_fence:
                in_fence = True
                fence_marker = marker[0]
            elif marker[0] == fence_marker:
                in_fence = False
                fence_marker = ""
        elif not in_fence:
            heading = re.match(r"^###\s+(.+?)\s*$", line)
            if heading:
                title = re.sub(r"\s+#+\s*$", "", heading.group(1)).strip()
                heading_matches.append((f"### {title}", offset, offset + len(line)))
        offset += len(line)

    actual = [heading for heading, _, _ in heading_matches]
    if actual != SCOPE_SUBHEADINGS:
        failures.append(
            "scope subsections must be exactly: " + " > ".join(SCOPE_SUBHEADINGS)
        )
        return

    for index, (heading, _, content_start) in enumerate(heading_matches):
        content_end = (
            heading_matches[index + 1][1]
            if index + 1 < len(heading_matches)
            else len(scope)
        )
        content = scope[content_start:content_end]
        visible = re.sub(r"<!--.*?-->", "", content, flags=re.DOTALL).strip()
        if not visible:
            failures.append(f"scope subsection must not be empty: {heading}")


def markdown_section(text: str, heading: str) -> str:
    visible, _ = markdown_surfaces(text)
    match = re.search(rf"(?m)^{re.escape(heading)}\s*$", visible)
    if not match:
        return ""
    level = len(heading) - len(heading.lstrip("#"))
    following = visible[match.end() :]
    end = re.search(rf"(?m)^#{{1,{level}}}\s+", following)
    return following[: end.start()] if end else following


def normalized_source_url(value: str) -> str:
    parsed = urlsplit(value.strip())
    path = parsed.path.rstrip("/") or "/"
    return urlunsplit(
        (parsed.scheme.casefold(), parsed.netloc.casefold(), path, parsed.query, "")
    )


def validate_architecture_chapter(
    text: str,
    source_urls: set[str],
    implementation_path: Path,
    kit_root: Path,
    failures: list[str],
) -> None:
    architecture = markdown_section(text, "## Architecture")
    if not architecture:
        return

    matches = list(re.finditer(r"(?m)^###\s+(.+?)\s*$", architecture))
    actual = []
    for match in matches:
        title = re.sub(r"\s+#+\s*$", "", match.group(1)).strip()
        actual.append(f"### {title}")
    if actual != ARCHITECTURE_SUBHEADINGS:
        failures.append(
            "architecture subsections must be exactly: "
            + " > ".join(ARCHITECTURE_SUBHEADINGS)
        )
        return

    subsections: dict[str, str] = {}
    for index, match in enumerate(matches):
        name = actual[index]
        end = matches[index + 1].start() if index + 1 < len(matches) else len(architecture)
        content = architecture[match.end() : end].strip()
        subsections[name] = content
        if not content:
            failures.append(f"architecture subsection must not be empty: {name}")

    tradeoffs = subsections.get("### Design choices and tradeoffs", "")
    table_found = False
    lines = tradeoffs.splitlines()
    for index in range(len(lines) - 2):
        header = split_markdown_table_row(lines[index])
        separator = split_markdown_table_row(lines[index + 1])
        row = split_markdown_table_row(lines[index + 2])
        if (
            len(header) >= 2
            and len(separator) == len(header)
            and all(re.fullmatch(r":?-{3,}:?", cell) for cell in separator)
            and len(row) == len(header)
            and all(header)
            and any(row)
        ):
            table_found = True
            break
    if not table_found:
        failures.append(
            "Design choices and tradeoffs must contain a Markdown table with a data row"
        )

    guidance = subsections.get("### Architecture guidance", "")
    links = re.findall(r"(?<!!)\[[^\]]+\]\((https://[^)\s]+)(?:\s+\"[^\"]*\")?\)", guidance)
    if not 1 <= len(links) <= 3:
        failures.append("Architecture guidance must contain 1-3 official Microsoft links")
    normalized_manifest_urls = {normalized_source_url(url) for url in source_urls}
    for link in links:
        hostname = (urlsplit(link).hostname or "").casefold()
        if hostname != "microsoft.com" and not hostname.endswith(".microsoft.com"):
            failures.append(f"Architecture guidance link is not an official Microsoft URL: {link}")
        if normalized_source_url(link) not in normalized_manifest_urls:
            failures.append(
                f"Architecture guidance link is not recorded in the manifest sources: {link}"
            )

    visible, _ = markdown_surfaces(text)
    diagram_targets = re.findall(
        r"(!?)\[[^\]]*\]\(([^)\s]*assets/diagrams/[^)\s]+)(?:\s+\"[^\"]*\")?\)",
        visible,
    )
    for image_marker, target in diagram_targets:
        if image_marker != "!":
            failures.append(
                f"diagram must be embedded as an image with useful alt text: {target}"
            )
            continue
        image = re.search(
            rf"!\[([^\]]*)\]\({re.escape(target)}(?:\s+\"[^\"]*\")?\)",
            visible,
        )
        alt = re.sub(r"[*_`]", "", image.group(1)).strip() if image else ""
        if len(alt.split()) < 2 or len(alt) < 8 or alt.casefold() in {
            "architecture diagram",
            "diagram",
            "image",
        }:
            failures.append(f"diagram needs useful alt text: {target}")
        clean_target = target.split("#", 1)[0].split("?", 1)[0]
        if Path(clean_target).suffix.casefold() != ".svg":
            failures.append(f"referenced diagram must use rendered SVG: {target}")
            continue
        resolved = (implementation_path.parent / clean_target).resolve()
        try:
            resolved.relative_to(kit_root.resolve())
        except ValueError:
            failures.append(f"diagram path must stay inside the kit: {target}")
            continue
        editable = resolved.with_suffix(".excalidraw")
        if not resolved.is_file() or not editable.is_file():
            failures.append(
                f"referenced diagram needs paired .svg and .excalidraw files: {target}"
            )


def require_string_list(
    value,
    name: str,
    failures: list[str],
    *,
    allow_empty: bool = False,
) -> list[str]:
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item.strip() for item in value
    ):
        failures.append(f"{name} must be a list of non-empty strings")
        return []
    if not allow_empty and not value:
        failures.append(f"{name} must not be empty")
    return value


def require_mapping_list(value, name: str, failures: list[str]) -> list[dict]:
    if not isinstance(value, list) or any(not isinstance(item, dict) for item in value):
        failures.append(f"{name} must be a list of mappings")
        return []
    if not value:
        failures.append(f"{name} must not be empty")
    return value


def safe_relative_path(value: str) -> bool:
    candidate = PurePosixPath(value.replace("\\", "/"))
    return (
        not candidate.is_absolute()
        and not re.match(r"^[A-Za-z]:", value)
        and ".." not in candidate.parts
    )


def normalized_relative_path(value: str) -> str:
    return PurePosixPath(value.replace("\\", "/")).as_posix()


def is_fixture_path(value: str) -> bool:
    parts = [part.casefold() for part in PurePosixPath(value.replace("\\", "/")).parts]
    return any(part in FORBIDDEN_FIXTURE_PARTS for part in parts) or (
        bool(parts) and "fixture" in parts[-1]
    )


def validate_retained_metadata(
    value,
    label: str,
    failures: list[str],
) -> str:
    if not isinstance(value, str) or not value.strip():
        failures.append(f"{label} must be a non-empty concrete value")
        return ""
    cleaned = " ".join(value.split())
    normalized = re.sub(r"[^a-z0-9]+", " ", cleaned.casefold()).strip()
    generic_normalized = re.sub(r"^(?:a|an|the|this)\s+", "", normalized)
    if (
        generic_normalized in GENERIC_RETAINED_METADATA
        or PLACEHOLDER_PATTERN.search(cleaned)
        or SENTINEL_PATTERN.search(cleaned)
        or generic_normalized in {"n a", "none", "tbd", "to be determined", "unknown"}
    ):
        failures.append(f"{label} must name a concrete value")
        return ""
    return cleaned


def validate_retained_file_manifest(
    manifest: dict,
    leave_behind: list[str],
    failures: list[str],
) -> dict[str, dict[str, str]]:
    normalized_leave_behind: list[str] = []
    seen_leave_behind: set[str] = set()
    for relative in leave_behind:
        if not safe_relative_path(relative):
            continue
        normalized = normalized_relative_path(relative)
        if normalized in seen_leave_behind:
            failures.append(f"deliverables.leave_behind contains duplicate path: {normalized}")
        else:
            seen_leave_behind.add(normalized)
            normalized_leave_behind.append(normalized)
        if is_fixture_path(normalized):
            failures.append(f"fixture path cannot be a leave-behind: {normalized}")

    retained_files = manifest.get("retained_files")
    if not isinstance(retained_files, list) or not retained_files:
        failures.append("retained_files must be a non-empty top-level list of mappings")
        return {}
    if any(not isinstance(item, dict) for item in retained_files):
        failures.append("retained_files must contain only mappings")
        return {}

    metadata_by_path: dict[str, dict[str, str]] = {}
    duplicate_paths: set[str] = set()
    for index, item in enumerate(retained_files, 1):
        raw_path = item.get("path")
        if not isinstance(raw_path, str) or not raw_path.strip():
            failures.append(f"retained_files entry {index} needs a non-empty path")
            continue
        if not safe_relative_path(raw_path):
            failures.append(f"retained_files entry {index} path must stay inside the kit")
            continue
        path = normalized_relative_path(raw_path)
        if is_fixture_path(path):
            failures.append(f"fixture path cannot be an implementation file: {path}")
        consumer = validate_retained_metadata(
            item.get("consumer"),
            f"retained_files entry {index} consumer",
            failures,
        )
        purpose = validate_retained_metadata(
            item.get("operational_purpose"),
            f"retained_files entry {index} operational_purpose",
            failures,
        )
        if path in metadata_by_path:
            duplicate_paths.add(path)
            failures.append(f"retained_files contains duplicate path: {path}")
            continue
        metadata_by_path[path] = {
            "consumer": consumer,
            "operational_purpose": purpose,
        }

    leave_paths = set(normalized_leave_behind)
    retained_paths = set(metadata_by_path)
    for path in sorted(leave_paths - retained_paths):
        failures.append(f"retained_files is missing leave-behind path: {path}")
    for path in sorted(retained_paths - leave_paths):
        failures.append(f"retained_files contains path not in deliverables.leave_behind: {path}")
    for path in duplicate_paths:
        metadata_by_path.pop(path, None)
    return metadata_by_path


def split_markdown_table_row(line: str) -> list[str]:
    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return []
    return [cell.strip() for cell in stripped[1:-1].split("|")]


def table_paths(path_cell: str) -> list[str]:
    candidates = re.findall(r"\[[^\]]+\]\(([^)]+)\)", path_cell)
    if not candidates:
        candidates = re.findall(r"`([^`]+)`", path_cell)
    paths = []
    for candidate in candidates:
        clean = candidate.strip().split("#", 1)[0].split("?", 1)[0]
        if not clean or re.match(r"^(?:[a-z]+:)?//", clean, re.I):
            continue
        normalized = normalized_relative_path(clean)
        if normalized.startswith("implementation/"):
            paths.append(normalized)
        elif safe_relative_path(normalized):
            paths.append(normalized_relative_path(f"implementation/{normalized}"))
    return paths


def strip_markdown_comments(line: str, in_comment: bool) -> tuple[str, bool]:
    visible = ""
    remaining = line
    while remaining:
        if in_comment:
            comment_end = remaining.find("-->")
            if comment_end < 0:
                return visible, True
            in_comment = False
            remaining = remaining[comment_end + 3 :]
            continue
        comment_start = remaining.find("<!--")
        if comment_start < 0:
            visible += remaining
            break
        visible += remaining[:comment_start]
        remaining = remaining[comment_start + 4 :]
        in_comment = True
    return visible, in_comment


def update_html_region_stack(line: str, stack: list[str]) -> None:
    for match in RAW_HTML_TAG_PATTERN.finditer(line):
        name = match.group("name").casefold()
        if match.group("closing"):
            if name in stack:
                last = len(stack) - 1 - stack[::-1].index(name)
                del stack[last:]
            continue
        if name not in RAW_HTML_VOID_TAGS and not match.group("self_closing"):
            stack.append(name)


def starts_raw_html_region(line: str) -> bool:
    stripped = line.lstrip()
    if RAW_HTML_TAG_PATTERN.match(stripped):
        return True
    return bool(re.match(r"^<(?:\?|![A-Za-z]|\!\[CDATA\[)", stripped))


def markdown_surfaces(text: str) -> tuple[str, list[tuple[str, str]]]:
    visible_lines: list[str] = []
    blocks: list[tuple[str, str]] = []
    in_comment = False
    html_stack: list[str] = []
    pending_html_tag = ""
    fence_character = ""
    fence_length = 0
    language = ""
    body: list[str] = []

    for raw_line in text.splitlines():
        if fence_character:
            closing = re.fullmatch(r"\s{0,3}(`{3,}|~{3,})\s*", raw_line)
            if (
                closing
                and closing.group(1)[0] == fence_character
                and len(closing.group(1)) >= fence_length
            ):
                blocks.append((language, "\n".join(body)))
                fence_character = ""
                fence_length = 0
                language = ""
                body = []
                continue
            body.append(raw_line)
            continue

        line, in_comment = strip_markdown_comments(raw_line, in_comment)
        if pending_html_tag:
            pending_html_tag += "\n" + line
            if ">" in line:
                update_html_region_stack(pending_html_tag, html_stack)
                pending_html_tag = ""
            continue
        if html_stack:
            update_html_region_stack(line, html_stack)
            continue
        if re.match(r"^\s*</?[A-Za-z][A-Za-z0-9:_-]*(?:\s|$)", line) and ">" not in line:
            pending_html_tag = line
            continue
        if starts_raw_html_region(line):
            update_html_region_stack(line, html_stack)
            continue

        opening = re.match(r"^\s{0,3}(`{3,}|~{3,})(.*)$", line)
        if not opening:
            visible_lines.append(line)
            continue
        marker = opening.group(1)
        info = opening.group(2).strip()
        if marker[0] == "`" and "`" in info:
            continue
        first_info = info.split(maxsplit=1)[0] if info else ""
        if first_info.startswith("{.") and first_info.endswith("}"):
            first_info = first_info[2:-1]
        fence_character = marker[0]
        fence_length = len(marker)
        language = first_info.casefold()
        body = []

    return "\n".join(visible_lines), blocks


def fenced_command_blocks(text: str) -> list[tuple[str, str]]:
    return markdown_surfaces(text)[1]


def strip_command_comments(
    line: str,
    shell: str,
    in_block_comment: bool,
    quote: str,
) -> tuple[str, bool, str, str]:
    output: list[str] = []
    here_string_end = ""
    index = 0
    while index < len(line):
        if in_block_comment:
            comment_end = line.find("#>", index)
            if comment_end < 0:
                return "".join(output), True, quote, here_string_end
            in_block_comment = False
            index = comment_end + 2
            continue

        character = line[index]
        if quote:
            output.append(character)
            if shell == "powershell" and character == "`" and index + 1 < len(line):
                output.append(line[index + 1])
                index += 2
                continue
            if shell == "bash" and character == "\\" and quote != "'" and index + 1 < len(line):
                output.append(line[index + 1])
                index += 2
                continue
            if character == quote:
                if (
                    shell == "powershell"
                    and quote == "'"
                    and index + 1 < len(line)
                    and line[index + 1] == "'"
                ):
                    output.append("'")
                    index += 2
                    continue
                quote = ""
            index += 1
            continue

        if shell == "powershell" and line.startswith("<#", index):
            in_block_comment = True
            index += 2
            continue
        if (
            shell == "powershell"
            and line[index : index + 2] in {"@'", '@"'}
            and not line[index + 2 :].strip()
        ):
            here_string_end = line[index + 1] + "@"
            break
        if character in {"'", '"'}:
            quote = character
            output.append(character)
            index += 1
            continue
        if character == "#":
            if shell == "powershell" or index == 0 or line[index - 1].isspace() or line[index - 1] in ";|&(":
                break
        if character == "\\" and shell == "bash" and index + 1 < len(line):
            output.extend((character, line[index + 1]))
            index += 2
            continue
        output.append(character)
        index += 1
    return "".join(output), in_block_comment, quote, here_string_end


def parse_bash_heredoc_delimiter(
    line: str, index: int
) -> tuple[str, int] | None:
    delimiter: list[str] = []
    quote = ""
    while index < len(line):
        character = line[index]
        if quote:
            if character == quote:
                quote = ""
                index += 1
                continue
            if quote == '"' and character == "\\" and index + 1 < len(line):
                following = line[index + 1]
                if following in {'$', '`', '"', "\\"}:
                    delimiter.append(following)
                    index += 2
                    continue
                delimiter.append("\\")
                index += 1
                continue
            delimiter.append(character)
            index += 1
            continue
        if character.isspace() or character in ";&|()<>":
            break
        if character in {"'", '"'}:
            quote = character
            index += 1
            continue
        if character == "\\":
            if index + 1 >= len(line):
                return None
            delimiter.append(line[index + 1])
            index += 2
            continue
        delimiter.append(character)
        index += 1
    if quote or not delimiter:
        return None
    return "".join(delimiter), index


def bash_heredocs(
    line: str, initial_quote: str
) -> tuple[list[tuple[str, bool]], bool]:
    heredocs: list[tuple[str, bool]] = []
    quote = initial_quote
    index = 0
    while index < len(line):
        character = line[index]
        if quote:
            if character == "\\" and quote == '"' and index + 1 < len(line):
                index += 2
                continue
            if character == quote:
                quote = ""
            index += 1
            continue
        if character == "\\" and index + 1 < len(line):
            index += 2
            continue
        if character in {"'", '"'}:
            quote = character
            index += 1
            continue
        if line.startswith("<<", index) and not line.startswith("<<<", index):
            index += 2
            strip_tabs = index < len(line) and line[index] == "-"
            if strip_tabs:
                index += 1
            while index < len(line) and line[index].isspace():
                index += 1
            parsed = parse_bash_heredoc_delimiter(line, index)
            if parsed is None:
                return [], True
            delimiter, index = parsed
            heredocs.append((delimiter, strip_tabs))
            continue
        index += 1
    return heredocs, False


def command_lines(block: str, shell: str) -> list[str]:
    commands: list[str] = []
    in_block_comment = False
    quote = ""
    here_string_end = ""
    heredocs: list[tuple[str, bool]] = []
    pending_heredocs: list[tuple[str, bool]] = []
    pending = ""

    for raw_line in block.splitlines():
        if heredocs:
            delimiter, strip_tabs = heredocs[0]
            candidate = raw_line.lstrip("\t") if strip_tabs else raw_line
            if candidate == delimiter:
                heredocs.pop(0)
            continue
        if here_string_end:
            if raw_line.strip() == here_string_end:
                here_string_end = ""
            continue

        line = re.sub(
            r"^\s*(?:PS(?:\s+[^>\r\n]*)?>|\$(?=\s|$)|>{1,2}(?=\s|$))\s*",
            "",
            raw_line,
            count=1,
            flags=re.IGNORECASE,
        )
        initial_quote = quote
        line, in_block_comment, quote, opened_here_string = strip_command_comments(
            line, shell, in_block_comment, quote
        )

        if shell == "powershell":
            here_string_end = opened_here_string
        else:
            found_heredocs, ambiguous = bash_heredocs(line, initial_quote)
            if ambiguous:
                return []
            pending_heredocs.extend(found_heredocs)

        stripped = line.rstrip()
        if quote:
            pending += stripped + "\n"
            continue
        continuation = "`" if shell == "powershell" else "\\"
        if stripped.endswith(continuation):
            pending += stripped[:-1] + " "
            continue
        logical_line = pending + stripped
        pending = ""
        if logical_line.strip():
            commands.append(logical_line)
        heredocs = pending_heredocs
        pending_heredocs = []

    if (
        in_block_comment
        or quote
        or here_string_end
        or heredocs
        or pending_heredocs
        or pending.strip()
    ):
        return []
    return commands


def split_command_segments(line: str, shell: str) -> list[str]:
    segments: list[str] = []
    start = 0
    quote = ""
    index = 0
    while index < len(line):
        character = line[index]
        if quote:
            if (
                (shell == "powershell" and character == "`")
                or (shell == "bash" and character == "\\" and quote != "'")
            ) and index + 1 < len(line):
                index += 2
                continue
            if character == quote:
                quote = ""
            index += 1
            continue
        if character in {"'", '"'}:
            quote = character
            index += 1
            continue
        separator_length = 0
        if line.startswith(("&&", "||"), index):
            separator_length = 2
        elif character in {";", "|"} or (shell == "bash" and character == "&"):
            separator_length = 1
        if separator_length:
            segments.append(line[start:index].strip())
            index += separator_length
            start = index
            continue
        index += 1
    segments.append(line[start:].strip())
    return [segment for segment in segments if segment]


def powershell_segment_invokes_script(segment: str, script_name: str) -> bool:
    escaped_name = re.escape(script_name)
    unquoted_path = rf"(?:\.{{0,2}}[\\/])?scripts[\\/]{escaped_name}"
    quoted_path = rf"(?:\"{unquoted_path}\"|'{unquoted_path}')"
    path_token = rf"(?:{quoted_path}|{unquoted_path})"
    direct = rf"{unquoted_path}(?=$|\s)"
    call_operator = rf"(?:&|\.(?=\s))\s*{path_token}(?=$|\s)"
    option = r"(?:-(?:NoLogo|NoProfile|NonInteractive)|-ExecutionPolicy\s+\S+)"
    launcher = (
        rf"(?:pwsh|powershell)(?:\.exe)?(?:\s+{option})*\s+"
        rf"(?:-File\s+)?{path_token}(?=$|\s)"
    )

    assignment = re.match(r"^\$[A-Za-z_][A-Za-z0-9_:.-]*\s*=\s*(.+)$", segment)
    candidate = assignment.group(1).lstrip() if assignment else segment.lstrip()
    return bool(
        re.match(rf"(?:{direct}|{call_operator}|{launcher})", candidate, re.IGNORECASE)
    )


def bash_segment_invokes_script(segment: str, script_name: str) -> bool:
    escaped_name = re.escape(script_name)
    unquoted_path = rf"(?:\.{{0,2}}/)?scripts/{escaped_name}"
    quoted_path = rf"(?:\"{unquoted_path}\"|'{unquoted_path}')"
    path_token = rf"(?:{quoted_path}|{unquoted_path})"
    direct = rf"{unquoted_path}(?=$|\s)"
    dot_source = rf"\.\s+{path_token}(?=$|\s)"
    launcher = rf"(?:bash|sh)(?:\s+-[A-Za-z-]+)*\s+{path_token}(?=$|\s)"
    command = rf"(?:{direct}|{dot_source}|{launcher})"

    candidate = segment.lstrip()
    if re.match(command, candidate, re.IGNORECASE):
        return True
    assignment = re.match(
        r"^[A-Za-z_][A-Za-z0-9_]*\s*=\s*(?P<quote>[\"']?)"
        r"\$\(\s*(?P<command>.+?)\s*\)(?P=quote)\s*$",
        candidate,
    )
    return bool(
        assignment
        and re.match(command, assignment.group("command").lstrip(), re.IGNORECASE)
    )


def command_block_invokes_script(block: str, script_name: str, shell: str) -> bool:
    segment_validator = (
        powershell_segment_invokes_script
        if shell == "powershell"
        else bash_segment_invokes_script
    )
    for line in command_lines(block, shell):
        for segment in split_command_segments(line, shell):
            if segment_validator(segment, script_name):
                return True
    return False


def validate_script_invocations(
    implementation_text: str,
    script_pairs: list[tuple[str, str]],
    failures: list[str],
) -> None:
    blocks = fenced_command_blocks(implementation_text)
    powershell_blocks = [
        body for language, body in blocks if language in {"powershell", "pwsh"}
    ]
    bash_blocks = [body for language, body in blocks if language in {"bash", "sh"}]

    for powershell_name, bash_name in script_pairs:
        if not any(
            command_block_invokes_script(block, powershell_name, "powershell")
            for block in powershell_blocks
        ):
            failures.append(
                f"implementation/README.md must present a PowerShell command for scripts/{powershell_name}"
            )
        if not any(
            command_block_invokes_script(block, bash_name, "bash")
            for block in bash_blocks
        ):
            failures.append(
                f"implementation/README.md must present a Bash command for scripts/{bash_name}"
            )


def validate_retained_file_table(
    implementation_text: str,
    implementation_files: set[str],
    retained_metadata: dict[str, dict[str, str]],
    failures: list[str],
) -> None:
    visible_markdown, _ = markdown_surfaces(implementation_text)
    heading = re.search(
        rf"(?m)^{re.escape(RETAINED_TABLE_HEADING)}\s*$",
        visible_markdown,
    )
    if not heading:
        failures.append(
            "implementation/README.md must contain the Implementation files table"
        )
        return
    lines = visible_markdown[heading.end() :].splitlines()
    while lines and not lines[0].strip():
        lines.pop(0)
    if len(lines) < 2:
        failures.append("implementation-file table is missing its header or separator")
        return
    header = split_markdown_table_row(lines[0])
    expected_header = list(RETAINED_TABLE_COLUMNS)
    if header != expected_header:
        failures.append(
            "implementation-file table header must be: Type | File | Consumer"
        )
        return
    separator = split_markdown_table_row(lines[1])
    if len(separator) != 3 or any(
        not re.fullmatch(r":?-{3,}:?", cell) for cell in separator
    ):
        failures.append("implementation-file table must use a three-column Markdown separator")
        return

    table_metadata: dict[str, dict[str, str]] = {}
    duplicate_paths: set[str] = set()
    row_number = 0
    for line in lines[2:]:
        if not line.strip():
            break
        cells = split_markdown_table_row(line)
        if not cells:
            break
        row_number += 1
        if len(cells) != 3:
            failures.append(f"implementation-file table row {row_number} must have three columns")
            continue
        file_type = cells[0]
        if file_type not in IMPLEMENTATION_FILE_TYPES:
            failures.append(
                f"implementation-file table row {row_number} type must be one of: "
                f"{', '.join(IMPLEMENTATION_FILE_TYPES)}"
            )
        paths = table_paths(cells[1])
        if not paths:
            failures.append(
                f"implementation-file table row {row_number} must link at least one implementation artifact"
            )
            continue
        consumer = validate_retained_metadata(
            cells[2],
            f"implementation-file table row {row_number} consumer",
            failures,
        )
        for path in paths:
            if path in table_metadata:
                duplicate_paths.add(path)
                failures.append(f"implementation-file table contains duplicate path: {path}")
                continue
            table_metadata[path] = {
                "consumer": consumer,
            }

    table_paths_set = set(table_metadata)
    for path in sorted(implementation_files - table_paths_set):
        failures.append(f"implementation-file table is missing implementation artifact: {path}")
    for path in sorted(table_paths_set - implementation_files):
        failures.append(f"implementation-file table lists a missing implementation artifact: {path}")

    for path in sorted(set(retained_metadata) & table_paths_set - duplicate_paths):
        manifest_entry = retained_metadata[path]
        table_entry = table_metadata[path]
        if (
            manifest_entry["consumer"]
            and table_entry["consumer"] != manifest_entry["consumer"]
        ):
            failures.append(
                f"implementation-file table consumer does not match retained_files for: {path}"
            )


def validate_script(path: Path, role: str, failures: list[str]) -> str:
    text = read_text(path, failures)
    if "Set-StrictMode -Version Latest" not in text:
        failures.append(f"{path.name} must enable PowerShell strict mode")
    if not re.search(r"\$ErrorActionPreference\s*=\s*[\"']Stop[\"']", text):
        failures.append(f"{path.name} must stop on errors")
    if role == "preflight":
        if "__REQUIRED_" not in text:
            failures.append("preflight.ps1 must name and reject the __REQUIRED_*__ sentinel")
        if "Get-Command" not in text or "Test-Path" not in text:
            failures.append("preflight.ps1 must validate required tools and files")
        if not re.search(
            r"target[\s_-]*(?:scope|subscription|resource[\s_-]*group)"
            r"|approved[\s_-]*subscription"
            r"|approved[\s_-]*tenant"
            r"|resource[\s_-]*group[\s_-]*name",
            text,
            re.I,
        ):
            failures.append("preflight.ps1 must validate the approved target scope")
    if role == "remove":
        if "SupportsShouldProcess" not in text or "ShouldProcess" not in text:
            failures.append("remove.ps1 must use SupportsShouldProcess and ShouldProcess")
        if not re.search(r"implementationSession", text, re.IGNORECASE):
            failures.append("remove.ps1 must enforce an implementationSession marker")
        if not re.search(r"ConfirmImpact\s*=\s*[\"']High[\"']", text):
            failures.append("remove.ps1 must use high-impact confirmation")
    return text


def validate_bash_script(path: Path, role: str, failures: list[str]) -> str:
    text = read_text(path, failures)
    if not text.startswith("#!/usr/bin/env bash\n"):
        failures.append(f"{path.name} must use the portable Bash shebang")
    if not re.search(r"(?m)^set -euo pipefail\s*$", text):
        failures.append(f"{path.name} must use set -euo pipefail")
    if re.search(r"\bpwsh\b|PowerShell source|launcher\.ps1", text, re.I):
        failures.append(f"{path.name} must implement the workflow natively without PowerShell")
    if role == "preflight":
        if "__REQUIRED_" not in text:
            failures.append("preflight.sh must name and reject the __REQUIRED_*__ sentinel")
        if "command -v" not in text or not re.search(r"\[\[\s+-(?:f|d)\s+", text):
            failures.append("preflight.sh must validate required tools and files")
        if not re.search(
            r"target[\s_-]*(?:scope|subscription|resource[\s_-]*group)"
            r"|approved[\s_-]*subscription"
            r"|approved[\s_-]*tenant"
            r"|resource[\s_-]*group[\s_-]*name",
            text,
            re.I,
        ):
            failures.append("preflight.sh must validate the approved target scope")
    if role == "remove":
        if not re.search(r"implementationSession", text, re.IGNORECASE):
            failures.append("remove.sh must enforce an implementationSession marker")
        if not re.search(r"--confirm|\bread\s+-r\b", text):
            failures.append("remove.sh must require explicit confirmation")
    return text


def validate_local_references(
    text: str,
    source_path: Path,
    kit_dir: Path,
    failures: list[str],
) -> None:
    kit_dir = kit_dir.resolve()
    repository_root = kit_dir.parent.parent
    references = re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", text)
    references.extend(re.findall(r"<img[^>]+src=[\"']([^\"']+)[\"']", text, re.I))
    for reference in references:
        parts = reference.strip().split()
        if not parts:
            continue
        clean = parts[0].strip("<>")
        clean = clean.split("#", 1)[0].split("?", 1)[0]
        if (
            not clean
            or clean.startswith("#")
            or re.match(r"^(?:[a-z]+:)?//", clean, re.I)
            or clean.lower().startswith(("data:", "mailto:"))
        ):
            continue
        target = (source_path.parent / clean).resolve()
        try:
            target.relative_to(kit_dir)
            target_is_allowed = True
        except ValueError:
            try:
                relative_target = target.relative_to(repository_root)
            except ValueError:
                target_is_allowed = False
            else:
                collection = relative_target.parts[0] if relative_target.parts else ""
                entry = relative_target.parts[1] if len(relative_target.parts) > 1 else ""
                entry_root = repository_root / collection / entry
                target_is_allowed = (
                    collection == "sessions"
                    and bool(re.fullmatch(r"\d{2}-[a-z0-9-]+", entry))
                    and (entry_root / "session.yaml").is_file()
                ) or (
                    collection == "modules"
                    and bool(re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", entry))
                    and (entry_root / "module.yaml").is_file()
                )
        if not target_is_allowed:
            failures.append(
                f"{source_path.name} reference leaves the implementation kits: {reference}"
            )
            continue
        if not target.is_file() and not (
            target.is_dir()
            and (
                (target / "session.yaml").is_file()
                or (target / "module.yaml").is_file()
            )
        ):
            relative_source = source_path.relative_to(kit_dir).as_posix()
            failures.append(f"{relative_source} references a missing local file: {reference}")


def render_deck(session_dir: Path, failures: list[str]) -> None:
    npx = shutil.which("npx.cmd" if os.name == "nt" else "npx")
    if not npx:
        failures.append("Cannot render deck: npx is not available")
        return
    with tempfile.TemporaryDirectory(prefix="ai-governance-marp-") as temp_dir:
        output = Path(temp_dir) / "deck.html"
        result = subprocess.run(
            [
                npx,
                "--yes",
                "@marp-team/marp-cli@4.2.3",
                "deck.md",
                "--theme-set",
                "assets/theme/ai-governance.css",
                "--html",
                "--allow-local-files",
                "--output",
                str(output),
            ],
            cwd=session_dir,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode:
            failures.append(f"Marp render failed: {(result.stderr or result.stdout).strip()}")
        elif not output.is_file() or not output.stat().st_size:
            failures.append("Marp reported success but produced no HTML output")


def main() -> int:
    args = parse_args()
    root = args.kit_dir.resolve()
    failures: list[str] = []
    if not root.is_dir():
        raise SystemExit(f"Implementation kit directory does not exist: {root}")

    is_module = (root / "module.yaml").is_file()
    manifest_name = "module.yaml" if is_module else "session.yaml"
    entity_name = "module" if is_module else "session"
    scope_heading = "## Module scope" if is_module else "## Session scope"

    for relative in [manifest_name, *REQUIRED_FILES]:
        if not (root / relative).is_file():
            failures.append(f"Missing required file: {relative}")
    for relative in FORBIDDEN_PATHS:
        if (root / relative).exists():
            failures.append(f"Obsolete path is forbidden: {relative}")
    implementation_root = root / "implementation"
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        name = path.name.casefold()
        if path.is_dir() and name in FORBIDDEN_PACKAGE_DIRS:
            failures.append(
                f"Proof and evidence package directories are forbidden: {relative.as_posix()}"
            )
        if name in FORBIDDEN_FIXTURE_PARTS or (
            path.is_file() and "fixture" in name
        ):
            failures.append(f"Lab test fixtures are forbidden: {relative.as_posix()}")
        if path.name.casefold() in LEGACY_NAMES:
            failures.append(f"Legacy path is forbidden: {relative}")

    manifest_path = root / manifest_name
    implementation_path = root / "implementation" / "README.md"
    deck_path = root / "deck.md"
    manifest_text = read_text(manifest_path, failures)
    implementation_text = read_text(implementation_path, failures)
    deck = read_text(deck_path, failures)

    try:
        manifest = parse_yaml(manifest_text)
    except ValueError as error:
        failures.append(f"{manifest_name} is invalid: {error}")
        manifest = {}

    if manifest.get("schema_version") != 2:
        failures.append(f"{manifest_name} schema_version must be 2")
    for key in sorted(OBSOLETE_MANIFEST_KEYS):
        if key in manifest:
            failures.append(f"{manifest_name} contains obsolete field: {key}")

    entity = manifest.get(entity_name)
    if not isinstance(entity, dict):
        failures.append(f"{entity_name} must be a mapping")
        entity = {}
    slug, title = (entity.get(key) for key in ("slug", "title"))
    if is_module:
        if slug and root.name != slug:
            failures.append("Module directory must match module.slug")
    else:
        session_id = entity.get("id")
        if session_id and slug and root.name != f"{session_id}-{slug}":
            failures.append(f"Session directory must be named {session_id}-{slug}")
        if not isinstance(session_id, str) or not re.fullmatch(r"\d{2}", session_id):
            failures.append("session.id must be a two-digit string")
    if not isinstance(slug, str) or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", slug):
        failures.append(f"{entity_name}.slug must be lower-case kebab-case")
    if not isinstance(title, str) or not title.strip():
        failures.append(f"{entity_name}.title must be a non-empty string")
    duration = entity.get("duration_minutes")
    if not isinstance(duration, int) or not 30 <= duration <= 480:
        failures.append(f"{entity_name}.duration_minutes must be an integer between 30 and 480")
    if not isinstance(entity.get("status"), str) or not entity["status"].strip():
        failures.append(f"{entity_name}.status must be a non-empty string")
    try:
        date.fromisoformat(str(entity.get("last_verified", "")))
    except ValueError:
        failures.append(f"{entity_name}.last_verified must use YYYY-MM-DD")
    list_keys = ("audience", "prerequisites", "related_sessions") if is_module else (
        "audience",
        "prerequisites",
        "dependencies",
    )
    for key in list_keys:
        require_string_list(entity.get(key), f"{entity_name}.{key}", failures)
    if not isinstance(entity.get("control_objective"), str) or not entity[
        "control_objective"
    ].strip():
        failures.append(f"{entity_name}.control_objective must be a non-empty string")

    implementation = manifest.get("implementation")
    if not isinstance(implementation, dict):
        failures.append("implementation must be a mapping")
        implementation = {}
    mode = implementation.get("mode")
    if mode not in {"standard", "extended"}:
        failures.append("implementation.mode must be standard or extended")
    extended_reason = implementation.get("extended_reason")
    if mode == "extended" and (
        not isinstance(extended_reason, str) or not extended_reason.strip()
    ):
        failures.append("extended mode requires implementation.extended_reason")
    if mode == "standard" and "extended_reason" in implementation:
        failures.append("standard mode must omit implementation.extended_reason")

    outcomes = require_string_list(
        manifest.get("implementation_outcomes"),
        "implementation_outcomes",
        failures,
    )
    if not 3 <= len(outcomes) <= 5:
        failures.append(f"{manifest_name} must define 3-5 implementation outcomes")
    if len({outcome.casefold() for outcome in outcomes}) != len(outcomes):
        failures.append("implementation outcomes must be unique")

    deliverables = manifest.get("deliverables")
    if not isinstance(deliverables, dict):
        failures.append("deliverables must be a mapping")
        deliverables = {}
    if deliverables.get("implementation") != "implementation/README.md":
        failures.append("deliverables.implementation must be implementation/README.md")
    if deliverables.get("deck") != "deck.md":
        failures.append("deliverables.deck must be deck.md")
    for obsolete in ("guide", "runbook"):
        if obsolete in deliverables:
            failures.append(f"deliverables contains obsolete field: {obsolete}")
    leave_behind = require_string_list(
        deliverables.get("leave_behind"),
        "deliverables.leave_behind",
        failures,
    )
    for relative in leave_behind:
        if not safe_relative_path(relative):
            failures.append(f"leave-behind path must stay inside the kit: {relative}")
        elif not (root / relative).is_file():
            failures.append(f"leave-behind path does not exist: {relative}")
    retained_metadata = validate_retained_file_manifest(
        manifest,
        leave_behind,
        failures,
    )
    retained_artifacts = [
        path
        for path in (root / "implementation" / "artifacts").rglob("*")
        if path.is_file() and path.name.casefold() != "readme.md"
    ]
    if not retained_artifacts:
        failures.append("implementation/artifacts must contain a implementation file, not only README.md")
    if not any(
        relative.replace("\\", "/").startswith("implementation/artifacts/")
        and PurePosixPath(relative.replace("\\", "/")).name.casefold() != "readme.md"
        for relative in leave_behind
    ):
        failures.append("deliverables.leave_behind must include a implementation artifact")

    sources = require_mapping_list(manifest.get("sources"), "sources", failures)
    source_urls: set[str] = set()
    for index, source in enumerate(sources, 1):
        for key in ("title", "url", "accessed", "supports"):
            if not isinstance(source.get(key), str) or not source[key].strip():
                failures.append(f"source {index} needs {key}")
        url = source.get("url")
        if isinstance(url, str) and not url.startswith("https://"):
            failures.append(f"source {index} url must use HTTPS")
        elif isinstance(url, str):
            source_urls.add(url)
        try:
            date.fromisoformat(str(source.get("accessed", "")))
        except ValueError:
            failures.append(f"source {index} accessed must use YYYY-MM-DD")

    if scope_heading not in implementation_text:
        failures.append(f"implementation/README.md is missing required heading: {scope_heading}")
    require_implementation_chapters(implementation_text, scope_heading, failures)
    validate_scope_subsections(implementation_text, scope_heading, failures)
    validate_architecture_chapter(
        implementation_text,
        source_urls,
        implementation_path,
        root,
        failures,
    )
    implementation_files = {
        path.relative_to(root).as_posix() for path in retained_artifacts
    }
    validate_retained_file_table(
        implementation_text,
        implementation_files,
        retained_metadata,
        failures,
    )
    if mode == "extended":
        if not re.search(r"\bintended[\s-]+path\b", implementation_text, re.I):
            failures.append("extended implementation must name an intended-path check")
        if not re.search(r"\b(?:blocked|failure)[\s-]+path\b", implementation_text, re.I):
            failures.append("extended implementation must name a blocked or failure-path check")
        if not re.search(r"\bdelivery[\s-]+owner checkpoint\b", implementation_text, re.I):
            failures.append("extended implementation must name a delivery-owner checkpoint")
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() in BINARY_SUFFIXES:
            continue
        relative = path.relative_to(root).as_posix()
        text = read_text(path, failures)
        if PLACEHOLDER_PATTERN.search(text):
            failures.append(f"{relative} still contains a scaffold placeholder")
        sentinels = SENTINEL_PATTERN.findall(text)
        if sentinels and not (
            relative.startswith("implementation/artifacts/")
            or relative
            in {
                "implementation/scripts/preflight.ps1",
                "implementation/scripts/preflight.sh",
            }
        ):
            failures.append(
                f"Decision sentinel is only allowed under implementation/artifacts: {relative}"
            )

    preflight_path = root / "implementation" / "scripts" / "preflight.ps1"
    preflight = validate_script(preflight_path, "preflight", failures)
    preflight_bash_path = root / "implementation" / "scripts" / "preflight.sh"
    preflight_bash = validate_bash_script(preflight_bash_path, "preflight", failures)
    preview_text = f"{implementation_text}\n{preflight}\n{preflight_bash}"
    if not re.search(
        r"\bwhat-if\b|read-only deployment preview|previewSupported",
        preview_text,
        re.I,
    ):
        failures.append(
            "implementation must run a read-only preview or explicitly record that preview is unsupported"
        )
    artifact_sentinels = set()
    artifact_root = root / "implementation" / "artifacts"
    if artifact_root.is_dir():
        for path in artifact_root.rglob("*"):
            if path.is_file() and path.suffix.lower() not in BINARY_SUFFIXES:
                artifact_sentinels.update(SENTINEL_PATTERN.findall(read_text(path, failures)))
    for sentinel in sorted(artifact_sentinels):
        if sentinel not in preflight:
            failures.append(f"preflight.ps1 does not name artifact sentinel: {sentinel}")
        if sentinel not in preflight_bash:
            failures.append(f"preflight.sh does not name artifact sentinel: {sentinel}")

    scripts_root = root / "implementation" / "scripts"
    script_pairs: list[tuple[str, str]] = []
    for powershell_path in scripts_root.glob("*.ps1"):
        bash_path = powershell_path.with_suffix(".sh")
        if not bash_path.is_file():
            failures.append(f"{powershell_path.name} is missing Bash counterpart: {bash_path.name}")
            continue
        script_pairs.append((powershell_path.name, bash_path.name))
        role = powershell_path.stem if powershell_path.stem in {"preflight", "remove", "verify"} else "script"
        validate_bash_script(bash_path, role, failures)
    validate_script_invocations(implementation_text, script_pairs, failures)
    for bash_path in scripts_root.glob("*.sh"):
        powershell_path = bash_path.with_suffix(".ps1")
        if not powershell_path.is_file():
            failures.append(f"{bash_path.name} is missing PowerShell counterpart: {powershell_path.name}")

    for powershell_path in implementation_root.rglob("*.ps1"):
        if powershell_path.parent == scripts_root:
            continue
        bash_path = powershell_path.with_suffix(".sh")
        relative = powershell_path.relative_to(root).as_posix()
        if not bash_path.is_file():
            failures.append(f"{relative} is missing Bash counterpart: {bash_path.name}")
            continue
        validate_bash_script(bash_path, "script", failures)
    for bash_path in implementation_root.rglob("*.sh"):
        if bash_path.parent == scripts_root:
            continue
        powershell_path = bash_path.with_suffix(".ps1")
        relative = bash_path.relative_to(root).as_posix()
        if not powershell_path.is_file():
            failures.append(f"{relative} is missing PowerShell counterpart: {powershell_path.name}")

    powershell_blocks = re.findall(
        r"```(?:powershell|pwsh)\s*\n.*?\n```",
        implementation_text,
        re.I | re.S,
    )
    paired_shell_blocks = re.findall(
        r"```(?:powershell|pwsh)\s*\n.*?\n```\s*\n```(?:bash|sh)\s*\n.*?\n```",
        implementation_text,
        re.I | re.S,
    )
    if len(paired_shell_blocks) != len(powershell_blocks):
        failures.append(
            "Every PowerShell command block in implementation/README.md must be followed by a Bash block"
        )

    remove_path = root / "implementation" / "scripts" / "remove.ps1"
    if remove_path.is_file():
        validate_script(remove_path, "remove", failures)
    verify_path = root / "implementation" / "scripts" / "verify.ps1"
    verify_paths = [
        path
        for path in root.rglob("*")
        if path.is_file() and path.name.casefold() == "verify.ps1"
    ]
    for candidate in verify_paths:
        relative = candidate.relative_to(root).as_posix()
        if mode == "standard":
            failures.append(f"standard kits must not include {relative}")
        elif candidate != verify_path:
            failures.append(
                f"extended verify.ps1 must use implementation/scripts/verify.ps1: {relative}"
            )
    if mode == "extended" and verify_path.is_file():
        validate_script(verify_path, "verify", failures)

    for setting in (
        "marp: true",
        "theme: ai-governance",
        "size: 16:9",
        "paginate: true",
        "html: true",
    ):
        if setting not in deck:
            failures.append(f"deck.md is missing Marp setting: {setting}")
    for slide_class in ("cover", "implementation", "closing"):
        if f"<!-- _class: {slide_class} -->" not in deck:
            failures.append(f"deck.md is missing required slide class: {slide_class}")
    if not re.search(r"(?im)^##\s+Why it matters\s*$", deck):
        failures.append("deck.md must contain a Why it matters slide")
    architecture_slide = re.search(r"(?im)^##\s+.*\bArchitecture\b.*$", deck)
    if not re.search(r"(?im)^##\s+(?:Control )?Boundar(?:y|ies)\s*$", deck):
        if not architecture_slide:
            failures.append("deck.md must contain a control boundary or architecture overview slide")
    if not architecture_slide:
        failures.append("deck.md must contain an architecture overview")
    if not re.search(r"(?im)^##\s+.*\bTradeoffs?\b.*$", deck):
        failures.append("deck.md must contain implementation tradeoffs")
    final_slide = re.split(r"(?m)^---\s*$", deck)[-1]
    final_visible_content = re.sub(
        r"<!--.*?-->",
        "",
        final_slide,
        flags=re.DOTALL,
    ).strip()
    if "<!-- _class: closing -->" not in final_slide:
        failures.append("deck.md final slide must use the closing class")
    if final_visible_content != "# Thank you!":
        failures.append("deck.md final slide must contain only the visible heading: Thank you!")
    if "<!-- _class: evidence -->" in deck:
        failures.append("deck.md still uses the obsolete evidence slide class")
    if len(re.findall(r"(?m)^---\s*$", deck)) < 9:
        failures.append("deck.md must contain at least eight slides")
    if not re.search(r"assets/(?:icons/microsoft|diagrams)/", deck):
        failures.append("deck.md must reference a purposeful diagram or service icon")
    validate_local_references(deck, deck_path, root, failures)
    validate_local_references(
        implementation_text,
        implementation_path,
        root,
        failures,
    )

    theme = read_text(root / "assets" / "theme" / "ai-governance.css", failures)
    if "/* @theme ai-governance */" not in theme:
        failures.append("Marp theme does not declare @theme ai-governance")
    for color in ("#1A77E3", "#032254", "#47494E", "#F5F8FE", "#E3E6ED"):
        if color not in theme:
            failures.append(f"Marp theme is missing RVAP token: {color}")

    generated = [
        path
        for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() in {".html", ".pdf"}
    ]
    if generated:
        failures.append("Generated deck output must not be kept in the kit")
    if any(path.is_dir() for path in root.rglob("__pycache__")):
        failures.append("Generated Python __pycache__ directories must not be kept in the kit")
    if args.render and not failures:
        render_deck(root, failures)

    if failures:
        print(f"{entity_name.title()} validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print(f"{entity_name.title()} kit is valid: {root}")
    if args.render:
        print("Marp deck rendered successfully to a temporary HTML file.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Fixes mis-encoded French text by normalising files to UTF-8."""

from __future__ import annotations

import pathlib
from typing import Dict, Iterable, List, Tuple

from ftfy import TextFixerConfig, fix_text

FTFY_CONFIG = TextFixerConfig(uncurl_quotes=False)

TEXT_EXTENSIONS = {
    ".arb",
    ".css",
    ".dart",
    ".html",
    ".json",
    ".md",
    ".sql",
    ".svg",
    ".txt",
    ".yaml",
    ".yml",
}

# Build a list of characters that are likely to appear in the app and that often
# suffer from mojibake when UTF-8 text is interpreted as ISO-8859-1 / CP1252.
TARGET_CODEPOINTS: Iterable[int] = (
    list(range(160, 256))  # Latin-1 supplement
    + [
        0x0152,  # Œ
        0x0153,  # œ
        0x0178,  # Ÿ
        0x0192,  # ƒ
        0x02DC,  # ˜
        0x2013,  # –
        0x2014,  # —
        0x2018,  # ‘
        0x2019,  # ’
        0x201A,  # ‚
        0x201C,  # “
        0x201D,  # ”
        0x201E,  # „
        0x2020,  # †
        0x2021,  # ‡
        0x2022,  # •
        0x2026,  # …
        0x2030,  # ‰
        0x2039,  # ‹
        0x203A,  # ›
        0x20AC,  # €
    ]
)


def build_replacement_map(max_rounds: int = 4) -> List[Tuple[str, str]]:
    """Generate mapping tuples (garbled, correct_char) sorted longest-first."""
    mapping: Dict[str, str] = {}

    for codepoint in TARGET_CODEPOINTS:
        char = chr(codepoint)
        garbled = char
        seen: set[str] = set()

        for _ in range(max_rounds):
            try:
                garbled = garbled.encode("utf-8").decode("cp1252")
            except UnicodeDecodeError:
                garbled = garbled.encode("utf-8").decode("latin-1")
            if garbled == char or garbled in seen:
                break
            seen.add(garbled)
            mapping[garbled] = char

    # Sort by descending length to ensure we replace the longest corrupted
    # sequences first (e.g. 'ÃƒÂ©' before 'Ã©').
    return sorted(mapping.items(), key=lambda item: len(item[0]), reverse=True)


REPLACEMENTS = build_replacement_map()


def normalise_text(text: str) -> Tuple[str, bool]:
    """Return text with mojibake sequences replaced and change flag."""
    updated = fix_text(text, config=FTFY_CONFIG)
    changed = updated != text

    for bad, good in REPLACEMENTS:
        if bad in updated:
            updated = updated.replace(bad, good)
    return updated, changed or updated != text


def process_file(path: pathlib.Path) -> bool:
    """Normalise a single file, returning True when modified."""
    try:
        original = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        # Try interpreting as cp1252 then re-write as UTF-8.
        raw = path.read_bytes()
        try:
            decoded = raw.decode("cp1252")
        except UnicodeDecodeError:
            return False
        path.write_text(decoded, encoding="utf-8")
        return True

    fixed, changed = normalise_text(original)
    if not changed:
        return False
    path.write_text(fixed, encoding="utf-8")
    return True


def main() -> None:
    modified: List[str] = []

    for path in pathlib.Path(".").rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        if process_file(path):
            modified.append(str(path))

    if modified:
        print("Updated files:")
        for item in modified:
            print(item)


if __name__ == "__main__":
    main()

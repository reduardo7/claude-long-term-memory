#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
PreCompact hook — injects a reminder to persist session memory before the
context window is compacted and prior conversation details are lost.

If an active daily log exists, asks Claude to update it now. If no log
exists but git changes are present, asks Claude to create one. The
compaction will discard unsaved context, so this reminder fires before
that happens.
"""

import glob
import json
import os
import subprocess
import sys


def has_git_changes(project_dir: str) -> bool:
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=5,
        )
        return bool(result.stdout.strip())
    except Exception:
        return False


def main():
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    daily_dir = os.path.join(project_dir, "memory", "daily") if project_dir else ""

    existing = []
    if daily_dir:
        existing = [f for f in glob.glob(os.path.join(daily_dir, "*.md"))
                    if not f.endswith(".gitkeep")]

    if existing:
        message = (
            "<memory-pre-compact-reminder>"
            "ANTES DEL COMPACTADO: actualizar ahora memory/daily/ con todo lo relevante "
            "de esta sesión — Decisiones, Errores y correcciones, Aprendizajes, Referencias. "
            "El compactado descartará el historial de conversación; lo que no esté en el "
            "archivo de sesión se perderá permanentemente."
            "</memory-pre-compact-reminder>"
        )
    elif project_dir and has_git_changes(project_dir):
        message = (
            "<memory-pre-compact-reminder>"
            "ANTES DEL COMPACTADO: se modificaron archivos en esta sesión pero no existe "
            "memory/daily/. Crear AHORA memory/daily/YYYY-MM-DD_HHMMSS.md con topic, "
            "Contexto, Decisiones, Errores y correcciones, Aprendizajes y Referencias. "
            "El compactado descartará el historial — guardar antes de que se pierda."
            "</memory-pre-compact-reminder>"
        )
    else:
        message = (
            "<memory-pre-compact-reminder>"
            "ANTES DEL COMPACTADO: si hubo decisiones, errores o aprendizajes en esta sesión, "
            "crear memory/daily/YYYY-MM-DD_HHMMSS.md ahora (ver memory/memory.md). "
            "El compactado descartará el historial de conversación."
            "</memory-pre-compact-reminder>"
        )

    print(json.dumps({"systemMessage": message}))
    sys.exit(0)


if __name__ == "__main__":
    main()

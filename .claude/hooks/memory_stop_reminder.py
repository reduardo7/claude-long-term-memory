#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
Stop hook — inyecta un recordatorio para registrar decisiones, errores y
aprendizajes en memory/daily/ antes de terminar la sesión.

Si ya existe un archivo de sesión en memory/daily/, el recordatorio pide
actualizarlo. Si no existe, detecta si hubo cambios git para determinar
si la sesión fue no trivial — en ese caso el recordatorio es imperativo.

El JSON impreso en stdout se inyecta como systemMessage al finalizar
la respuesta (comportamiento de Claude Code Stop hooks).
"""

import glob
import json
import os
import subprocess
import sys


def is_git_available() -> bool:
    try:
        subprocess.run(["git", "--version"], capture_output=True, timeout=3)
        return True
    except Exception:
        return False


def is_git_repo(project_dir: str) -> bool:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=3,
        )
        return result.returncode == 0
    except Exception:
        return False


def has_git_changes(project_dir: str) -> bool:
    """Detecta si hubo cambios en el worktree (staged, unstaged o untracked)."""
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
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR")
    if not project_dir:
        message = (
            "<memory-stop-reminder>"
            "OBLIGATORIO si hubo trabajo no trivial: crear memory/daily/YYYY-MM-DD_HHMMSS.md "
            "con topic, Contexto, Decisiones, Errores y correcciones, Aprendizajes, Referencias."
            "</memory-stop-reminder>"
        )
        print(json.dumps({"systemMessage": message}))
        sys.exit(0)

    daily_dir = os.path.join(project_dir, "memory", "daily")
    pattern = os.path.join(daily_dir, "*.md")
    existing_files = [f for f in glob.glob(pattern) if not f.endswith(".gitkeep")]

    if existing_files:
        message = (
            "<memory-stop-reminder>"
            "Hay un archivo de sesión activo en memory/daily/. "
            "Actualizar ahora las secciones que correspondan: "
            "Decisiones, Errores y correcciones, Aprendizajes, Referencias."
            "</memory-stop-reminder>"
        )
    else:
        git_changed = (
            is_git_available()
            and is_git_repo(project_dir)
            and has_git_changes(project_dir)
        )
        if git_changed:
            message = (
                "<memory-stop-reminder>"
                "ATENCIÓN: se modificaron archivos en esta sesión pero NO existe memory/daily/. "
                "Crear AHORA memory/daily/YYYY-MM-DD_HHMMSS.md con topic, Contexto, "
                "Decisiones, Errores y correcciones, Aprendizajes y Referencias. "
                "No omitir — es obligatorio cuando hay trabajo no trivial."
                "</memory-stop-reminder>"
            )
        else:
            message = (
                "<memory-stop-reminder>"
                "Si hubo decisiones, errores o aprendizajes en esta sesión (aunque no haya "
                "archivos modificados), crear memory/daily/YYYY-MM-DD_HHMMSS.md según memory.md."
                "</memory-stop-reminder>"
            )

    print(json.dumps({"systemMessage": message}))
    sys.exit(0)


if __name__ == "__main__":
    main()

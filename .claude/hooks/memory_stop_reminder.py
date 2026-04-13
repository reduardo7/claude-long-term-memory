#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
Stop hook — injects a contextual reminder to record decisions, errors, and
learnings in memory/daily/ before ending the session.

If a session file already exists in memory/daily/, the reminder asks to
update it. If none exists, it reminds Claude to create one only if there
was significant work.

JSON printed to stdout is injected as a systemMessage at the end of
the response (Claude Code Stop hook behavior).
"""

import glob
import json
import os
import sys


def main():
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR")
    if not project_dir:
        # Cannot determine project directory — show generic reminder and exit
        message = (
            "<memory-stop-reminder>"
            "If there were decisions, errors, or learnings in this session, "
            "record them in memory/daily/ according to memory/memory.md."
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
            "There is an active session file in memory/daily/. "
            "If something significant happened, update the corresponding sections "
            "(Decisions, Errors and corrections, Learnings, References) before finishing."
            "</memory-stop-reminder>"
        )
    else:
        message = (
            "<memory-stop-reminder>"
            "If there were decisions, errors, or learnings in this session, "
            "record them in memory/daily/ according to memory/memory.md."
            "</memory-stop-reminder>"
        )

    print(json.dumps({"systemMessage": message}))
    sys.exit(0)


if __name__ == "__main__":
    main()

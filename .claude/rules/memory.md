---
paths:
  - "memory/**/*"
  - ".claude/agents/memory-*.md"
  - ".claude/commands/memory-digest.md"
  - ".claude/hooks/memory_*.py"
---

# Long-Term Memory System

## Mandatory reading

Before creating or modifying any file in `memory/` or the `memory-digest` command, read:

- `memory/memory.md` — complete operating instructions: what to record, daily file format, distillation flow.
- `docs/vault/Claude/Memory.md` — memory system documentation in the vault: architecture, entry classification, destination table.

## Mandatory documentation update

When creating, modifying, or deleting files in `memory/` or `.claude/commands/memory-digest.md`:

1. If the flow, classification, or rules of the memory system change, **reflect the changes** in `docs/vault/Claude/Memory.md` and in `memory/memory.md` in the same commit.
2. If a new document is created in `docs/vault/Claude/`, verify whether it requires its own Claude Rule in `.claude/rules/` (see the pattern in existing files in that folder).

**Never** complete a task that modifies the memory system without verifying that `memory/memory.md` and `docs/vault/Claude/Memory.md` are in sync.

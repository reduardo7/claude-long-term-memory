#!/usr/bin/env bash
# claude-long-term-memory — install script
# Usage: bash install.sh /path/to/target-project

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: bash install.sh /path/to/target-project"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: target directory '$TARGET' does not exist"
  exit 1
fi

echo "Installing claude-long-term-memory into: $TARGET"
echo ""

# Create directories
mkdir -p "$TARGET/memory/daily"
mkdir -p "$TARGET/docs/vault/Claude"
mkdir -p "$TARGET/docs/vault/Decisiones"
mkdir -p "$TARGET/docs/vault/Arquitectura"
mkdir -p "$TARGET/docs/vault/Desarrollo"
mkdir -p "$TARGET/docs/vault/Proyecto"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude/rules"
mkdir -p "$TARGET/.claude/hooks"

# Copy memory system files
echo "→ Copying memory/"
cp "$PLUGIN_DIR/memory/memory.md" "$TARGET/memory/memory.md"
touch "$TARGET/memory/daily/.gitkeep"

# Copy vault template (only if not already present)
echo "→ Copying docs/vault/ (skipping existing files)"
copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -f "$dst" ]]; then
    echo "  SKIP (exists): $dst"
  else
    cp "$src" "$dst"
    echo "  CREATED: $dst"
  fi
}

copy_if_missing "$PLUGIN_DIR/docs/vault/Home.md"                          "$TARGET/docs/vault/Home.md"
copy_if_missing "$PLUGIN_DIR/docs/vault/Claude/Memory.md"                 "$TARGET/docs/vault/Claude/Memory.md"
copy_if_missing "$PLUGIN_DIR/docs/vault/Decisiones/Index.md"              "$TARGET/docs/vault/Decisiones/Index.md"
copy_if_missing "$PLUGIN_DIR/docs/vault/Desarrollo/Obsidian Vault.md"     "$TARGET/docs/vault/Desarrollo/Obsidian Vault.md"
copy_if_missing "$PLUGIN_DIR/docs/vault/Desarrollo/Comportamientos Esperados.md" "$TARGET/docs/vault/Desarrollo/Comportamientos Esperados.md"

# Copy Claude commands
echo "→ Copying .claude/commands/"
cp "$PLUGIN_DIR/.claude/commands/memory-digest.md" "$TARGET/.claude/commands/memory-digest.md"
echo "  CREATED: .claude/commands/memory-digest.md"
copy_if_missing "$PLUGIN_DIR/.claude/commands/conditional_docs.md" "$TARGET/.claude/commands/conditional_docs.md"

# Copy Claude agents
echo "→ Copying .claude/agents/"
cp "$PLUGIN_DIR/.claude/agents/memory-digest-daily.md" "$TARGET/.claude/agents/memory-digest-daily.md"
cp "$PLUGIN_DIR/.claude/agents/memory-digest-spec.md"  "$TARGET/.claude/agents/memory-digest-spec.md"
cp "$PLUGIN_DIR/.claude/agents/memory-search.md"       "$TARGET/.claude/agents/memory-search.md"
echo "  CREATED: .claude/agents/memory-digest-daily.md"
echo "  CREATED: .claude/agents/memory-digest-spec.md"
echo "  CREATED: .claude/agents/memory-search.md"

# Copy Claude rules
echo "→ Copying .claude/rules/"
cp "$PLUGIN_DIR/.claude/rules/memory.md"        "$TARGET/.claude/rules/memory.md"
cp "$PLUGIN_DIR/.claude/rules/obsidian-vault.md" "$TARGET/.claude/rules/obsidian-vault.md"
echo "  CREATED: .claude/rules/memory.md"
echo "  CREATED: .claude/rules/obsidian-vault.md"

# Copy hooks
echo "→ Copying .claude/hooks/"
cp "$PLUGIN_DIR/.claude/hooks/memory_search_reminder.py"    "$TARGET/.claude/hooks/memory_search_reminder.py"
cp "$PLUGIN_DIR/.claude/hooks/memory_stop_reminder.py"      "$TARGET/.claude/hooks/memory_stop_reminder.py"
cp "$PLUGIN_DIR/.claude/hooks/memory_pre_agent_reminder.py" "$TARGET/.claude/hooks/memory_pre_agent_reminder.py"
echo "  CREATED: .claude/hooks/memory_search_reminder.py"
echo "  CREATED: .claude/hooks/memory_stop_reminder.py"
echo "  CREATED: .claude/hooks/memory_pre_agent_reminder.py"

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Add hooks to $TARGET/.claude/settings.json  (see settings-hooks.json)"
echo "  2. Append CLAUDE.md.snippet.md to $TARGET/CLAUDE.md"
echo "  3. Customize docs/vault/Home.md for your project"
echo "  4. Update the skills table in .claude/agents/memory-digest-daily.md"
echo ""
echo "See README.md for full details."

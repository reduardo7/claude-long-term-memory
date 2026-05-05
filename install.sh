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
mkdir -p "$TARGET/docs/vault/Decisions"
mkdir -p "$TARGET/docs/vault/Architecture"
mkdir -p "$TARGET/docs/vault/Development"
mkdir -p "$TARGET/docs/vault/Project"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude/rules"

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
copy_if_missing "$PLUGIN_DIR/docs/vault/Decisions/Index.md"               "$TARGET/docs/vault/Decisions/Index.md"
copy_if_missing "$PLUGIN_DIR/docs/vault/Development/Obsidian Vault.md"    "$TARGET/docs/vault/Development/Obsidian Vault.md"
copy_if_missing "$PLUGIN_DIR/docs/vault/Development/Expected Behaviors.md" "$TARGET/docs/vault/Development/Expected Behaviors.md"

# Copy Claude commands
echo "→ Copying .claude/commands/"
cp "$PLUGIN_DIR/.claude/commands/memory-digest.md" "$TARGET/.claude/commands/memory-digest.md"
echo "  CREATED: .claude/commands/memory-digest.md"
copy_if_missing "$PLUGIN_DIR/.claude/commands/conditional-docs.md" "$TARGET/.claude/commands/conditional-docs.md"

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

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Customize docs/vault/Home.md for your project"
echo "  2. Update the skills table in .claude/agents/memory-digest-daily.md"
echo ""
echo "See README.md for full details."

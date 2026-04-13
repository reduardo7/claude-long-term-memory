# claude-long-term-memory

A drop-in long-term memory system for Claude Code projects. Captures session decisions, errors, and discoveries in raw daily logs, then distills them into a curated Obsidian vault via the `/memory-digest` command.

---

## How it works

```
Session work
  └─→ memory/daily/<timestamp>.md   (raw, ephemeral — Claude writes in real time)

/memory-digest  (orchestrator, Opus model)
  ├─→ [each daily log] → memory-digest-daily sub-agent
  │       └─→ extracts durable knowledge → docs/vault/...
  │       └─→ deletes memory/daily/<ts>.md
  │
  └─→ [each undigested spec] → memory-digest-spec sub-agent
          └─→ extracts decisions and rationale → docs/vault/...
          └─→ records basename in specs/digested.txt

docs/vault/  (curated, permanent, cross-linked Obsidian vault)
```

**Three hooks** reinforce the system automatically:

| Hook | Trigger | Effect |
|------|---------|--------|
| `memory_search_reminder.py` | Every user prompt | Reminds Claude to invoke `memory-search` before non-trivial tasks |
| `memory_pre_agent_reminder.py` | Before any sub-agent | Reminds Claude to include vault context in the sub-agent prompt |
| `memory_stop_reminder.py` | End of every response | Reminds Claude to log decisions/errors before the session closes |

---

## Setup

### Step 1 — Run the install script

```bash
bash /path/to/claude-long-term-memory/install.sh /path/to/your-project
```

This creates the required directories and copies all files into your project. Existing files are never overwritten.

<details>
<summary>Manual installation (alternative)</summary>

```bash
# From your project root
cp /path/to/claude-long-term-memory/memory/memory.md ./memory/memory.md
touch ./memory/daily/.gitkeep

cp /path/to/claude-long-term-memory/docs/vault/Home.md                            ./docs/vault/Home.md
cp /path/to/claude-long-term-memory/docs/vault/Claude/Memory.md                   ./docs/vault/Claude/Memory.md
cp /path/to/claude-long-term-memory/docs/vault/Decisiones/Index.md                ./docs/vault/Decisiones/Index.md
cp "/path/to/claude-long-term-memory/docs/vault/Desarrollo/Obsidian Vault.md"     "./docs/vault/Desarrollo/Obsidian Vault.md"
cp "/path/to/claude-long-term-memory/docs/vault/Desarrollo/Comportamientos Esperados.md" "./docs/vault/Desarrollo/Comportamientos Esperados.md"

cp /path/to/claude-long-term-memory/.claude/commands/memory-digest.md             ./.claude/commands/memory-digest.md
cp /path/to/claude-long-term-memory/.claude/commands/conditional_docs.md          ./.claude/commands/conditional_docs.md

cp /path/to/claude-long-term-memory/.claude/agents/memory-digest-daily.md         ./.claude/agents/memory-digest-daily.md
cp /path/to/claude-long-term-memory/.claude/agents/memory-digest-spec.md          ./.claude/agents/memory-digest-spec.md
cp /path/to/claude-long-term-memory/.claude/agents/memory-search.md               ./.claude/agents/memory-search.md

cp /path/to/claude-long-term-memory/.claude/rules/memory.md                       ./.claude/rules/memory.md
cp /path/to/claude-long-term-memory/.claude/rules/obsidian-vault.md               ./.claude/rules/obsidian-vault.md

cp /path/to/claude-long-term-memory/.claude/hooks/memory_search_reminder.py       ./.claude/hooks/memory_search_reminder.py
cp /path/to/claude-long-term-memory/.claude/hooks/memory_stop_reminder.py         ./.claude/hooks/memory_stop_reminder.py
cp /path/to/claude-long-term-memory/.claude/hooks/memory_pre_agent_reminder.py    ./.claude/hooks/memory_pre_agent_reminder.py
```
</details>

### Step 2 — Add hooks to `.claude/settings.json`

Merge the following into your project's `.claude/settings.json`. The full reference is also in `settings-hooks.json`.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "uv run $CLAUDE_PROJECT_DIR/.claude/hooks/memory_pre_agent_reminder.py || true"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv run $CLAUDE_PROJECT_DIR/.claude/hooks/memory_stop_reminder.py || true",
            "statusMessage": "Memory reminder"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv run $CLAUDE_PROJECT_DIR/.claude/hooks/memory_search_reminder.py || true"
          }
        ]
      }
    ]
  }
}
```

> For system-level installation (applies to all projects), use `~/.claude/settings.json` and replace `$CLAUDE_PROJECT_DIR/.claude/hooks/` with the absolute path to your hooks.

### Step 3 — Add the memory section to `CLAUDE.md`

Append `CLAUDE.md.snippet.md` to your project's `CLAUDE.md`:

```bash
cat /path/to/claude-long-term-memory/CLAUDE.md.snippet.md >> /path/to/your-project/CLAUDE.md
```

This ensures Claude always has the memory instructions loaded at the start of every session.

### Step 4 — Customize for your project

**Vault structure:** Edit `docs/vault/Home.md` to reflect your project's sections and documents.

**Conditional docs:** Edit `.claude/commands/conditional_docs.md` — add entries that map your project's task types to the specific vault documents Claude should read before working on them.

**Skills table:** Open `.claude/agents/memory-digest-daily.md` and `.claude/agents/memory-digest-spec.md`. Find the **Skills table** in Step 6 and replace the generic entries with your project's actual skill files (`.claude/skills/*/SKILL.md`).

---

## Usage

### During a session

Claude automatically records significant work in `memory/daily/<timestamp>.md`:

- Technical decisions → `## Decisions`
- User corrections → `## Errors and corrections`
- New discoveries → `## Learnings`
- Files touched → `## References`

You don't need to do anything — hooks and `CLAUDE.md` instructions handle this.

### Running `/memory-digest`

After one or more sessions, run:

```
/memory-digest
```

Claude will:
1. Process each `memory/daily/*.md` log with the `memory-digest-daily` sub-agent
2. Process any undigested files in `specs/*.md` with the `memory-digest-spec` sub-agent
3. Write durable knowledge to `docs/vault/`
4. Update relevant skill files in `.claude/skills/`
5. Create a git commit with all changes
6. Delete the processed daily logs

### Searching the vault

Before non-trivial tasks, Claude automatically invokes the `memory-search` sub-agent (triggered by the `UserPromptSubmit` hook). You can also invoke it manually:

```
Agent(subagent_type: "memory-search", prompt: "<task description>")
```

---

## File reference

| File | Purpose |
|------|---------|
| `memory/memory.md` | Operating instructions for Claude — what to record, when, and in what format |
| `memory/daily/*.md` | Raw session logs — ephemeral, deleted after `/memory-digest` |
| `docs/vault/Home.md` | Vault master index — update as vault grows |
| `docs/vault/Claude/Memory.md` | Memory system documentation in the vault |
| `docs/vault/Decisiones/Index.md` | ADR index — updated after every architectural decision |
| `docs/vault/Desarrollo/Obsidian Vault.md` | Vault writing conventions (naming, wikilinks) |
| `.claude/commands/memory-digest.md` | `/memory-digest` slash command (orchestrator) |
| `.claude/commands/conditional_docs.md` | Maps task types to vault documents — customize per project |
| `.claude/agents/memory-digest-daily.md` | Sub-agent: distills one daily log → vault + skills |
| `.claude/agents/memory-digest-spec.md` | Sub-agent: distills one spec file → vault + skills |
| `.claude/agents/memory-search.md` | Sub-agent: retrieves vault docs before tasks |
| `.claude/rules/memory.md` | Claude Rule: fires when memory/ or memory system files are touched |
| `.claude/rules/obsidian-vault.md` | Claude Rule: fires when docs/vault/ files are touched |
| `.claude/hooks/memory_search_reminder.py` | UserPromptSubmit hook: reminds Claude to search vault |
| `.claude/hooks/memory_stop_reminder.py` | Stop hook: reminds Claude to update session log |
| `.claude/hooks/memory_pre_agent_reminder.py` | PreToolUse[Agent] hook: reminds Claude to pass vault context |
| `settings-hooks.json` | Hook configuration snippet — merge into `.claude/settings.json` |
| `CLAUDE.md.snippet.md` | CLAUDE.md snippet — append to your project's CLAUDE.md |

---

## Customization

### Vault language

The sub-agents are configured to maintain the vault's established language (they check existing documents and match the language already in use). To enforce a specific language, edit the language instruction in Step 4 of `.claude/agents/memory-digest-daily.md` and `.claude/agents/memory-digest-spec.md`.

### Vault root path

The default vault path is `docs/vault/`. To change it, update all references in:
- `memory/memory.md`
- `.claude/agents/memory-digest-daily.md`
- `.claude/agents/memory-digest-spec.md`
- `.claude/agents/memory-search.md`
- `.claude/rules/obsidian-vault.md`
- `CLAUDE.md.snippet.md`

### Specs pipeline

The specs pipeline (`specs/*.md` → `memory-digest-spec`) is optional. If you don't use spec files, remove steps 3 and 4 from `.claude/commands/memory-digest.md`.

### Python interpreter

Hooks use `uv run` by default. To use plain `python3` instead, replace `uv run` with `python3` in each hook command in `.claude/settings.json`.

---

## Requirements

- Claude Code with hooks support
- `uv` installed (for running Python hooks) — or adapt hooks to use `python3`
- Python 3.11+

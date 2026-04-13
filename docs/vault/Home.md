---
tags: [moc, home]
---

# [Project Name] — Vault

Master content map. Open this vault from `docs/vault/` in Obsidian.

---

## Project

| Note | Description |
|------|-------------|
| [[Proyecto/PRD]] | Product Requirements Document — objectives, business rules, flows |

---

## Architecture

| Note | Description |
|------|-------------|
| [[Arquitectura/Project Structure]] | Repositories, layers, APIs, infrastructure |

---

## Decisions (ADRs)

> Navigable index of Architecture Decision Records. Rule: every decision with architectural, API contract, data model, or business behavior impact must be recorded here.

| Note | Scope |
|------|-------|
| [[Decisiones/Index]] | Master table of all ADRs with number, section, and link |

> Next ADR: **ADR-001**

---

## Development

| Note | Description |
|------|-------------|
| [[Desarrollo/Obsidian Vault]] | Vault writing rules and naming conventions |
| [[Desarrollo/Comportamientos Esperados]] | Intentional design decisions that are NOT bugs |

---

## Claude Code

| Note | Description |
|------|-------------|
| [[Claude/Memory]] | Long-term memory system — daily log, `/memory-digest`, distillation flow to vault |

---

## Relationship between documentation sources

| Source | Role |
|--------|------|
| **CLAUDE.md** | Absolute rules and source of truth — the *what* and the *why* |
| **`docs/vault/Decisiones/Index.md`** | ADR index. Consult before implementing; update when completing features |
| **`docs/vault/Home.md`** | This file — master map of all vault content |

---

## What is NOT in the vault

These resources live outside `docs/vault/` and should not be moved:
- `specs/` — implementation specs (immutable historical record)

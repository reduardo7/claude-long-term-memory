---
tags: [adr, index, architecture]
---

# ADR Index — Architecture Decision Records

> Navigable index of all technical and architectural decisions in the project.
> **Rule:** Every decision with impact on architecture, API contracts, data model, or business behavior must be recorded here.
> **Next ADR:** ADR-001

---

## How to maintain this document

- **New feature:** Add a row in the corresponding section with the next consecutive ADR number.
- **Changed decision:** Update the existing row. If the change is significant, add a note `(updated in #NNN)`.
- **Source of truth:** Specs are the detail; this file is the navigable index.

---

## Template: New ADR Section

```markdown
## [Domain Area] → [[Decisiones/ADR - Domain Area]]

| # | Decision summary | Issue |
|---|-----------------|-------|
| ADR-001 | [Decision taken and why] | #1 |
```

---

_No decisions recorded yet. Add sections as your project evolves._

---
name: decision-capture
description: Capture decisions made during a session (chose X over Y because Z) into the memory vault's Auto Memory/ for the groom run to promote. Use at the end of a piece of work, or when the user says "capture decisions", "log this decision", or "remember this decision".
---

# Decision capture

Decisions are the highest-value memory type; they are what code and git history do
not record. This skill writes them as raw capture into the memory vault
(`~/memory/Auto Memory/`), where the groom run promotes them into the
curated notes under `Decisions Index.md`.

## 1. Find the decisions

Scan the session for durable choices: an alternative was considered and rejected for
a reason that will matter again. The test: would a future session, or a teammate,
otherwise relitigate this?

Capture:

- Architecture and design choices ("runtime derivation on the entity over a stored
  status column, because the column went stale").
- Tooling and process choices ("launchd over cron for the weekly run").
- Scope calls with a reason ("held the helper methods back until their callers land").

Skip:

- Session-local calls with no future weight (which file to edit first).
- Anything the repo already records in an ADR, committed doc, or the diff itself.
- Preferences already covered by a standing rule in your agent config.

## 2. Write the capture

One file per decision in `Auto Memory/`, named `decision-YYYY-MM-DD-<slug>.md`:

```markdown
---
type: decision
date: YYYY-MM-DD
---

# <What was chosen, as a verb phrase>

Chose <X> over <Y> because <Z>. <One or two sentences of context a future session
needs; name real things: files, tables, tickets, PRs.>

Project: [[<project note>]]. People: [[<person note>]] (only if someone else was
part of the call).
```

Keep it to the decision, the rejected alternative, and the reason. Distill; no
transcript.

## 3. Do not promote

Promotion is the groom run's job (`memory-groom` step 2): a small decision becomes a
dated bullet in `Decisions Index.md`; one that needs room becomes its own root note
with `type: decision` frontmatter, rendered by `Decisions.base`. Sessions only write
the capture; commit and push the vault afterward.

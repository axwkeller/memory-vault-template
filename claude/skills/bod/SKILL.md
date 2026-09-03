---
name: bod
description: Open the day from the vault - groom yesterday's capture with the diff shown before one confirmation, and report what is open before planning. Use when the user says "bod", "beginning of day", "open the day", or "start the day".
---

# bod

Refuse to run unless `git rev-parse --show-toplevel` is `$HOME/memory` (adjust if
yours lives elsewhere); say to run this from the vault instead.

## 1. Groom yesterday's capture

Invoke the `memory-groom` skill by name with the `daily` scope. It promotes and prunes
everything in `Auto Memory/`, shows the whole diff, waits for one confirmation, then
commits or reverts. This skill edits no curated note itself; every change reaches the
tree through that confirmation.

## 2. Status

One block, facts only, no advice:

- Yesterday's `Daily/<yesterday>.md`: whether it exists, and what it holds.
- Unfinished work in the vault: `git status --short` and
  `git log --oneline @{upstream}..HEAD`. Name uncommitted files and unpushed commits.
- Watching: the bullets under `## Watching` in `Bearing.md`, when the section exists.
- A `.groom` marker at the vault root: a groom that did not finish. Say so and leave
  it; the user clears it after checking `git status`.

"Today" and "yesterday" come from the system date, not any external tool. Nothing in
this step is written anywhere.

## Rules

- Runs from the vault only.
- Writes nothing directly: the groom owns curated notes, and `Daily/` belongs to
  whatever writes the daily note.

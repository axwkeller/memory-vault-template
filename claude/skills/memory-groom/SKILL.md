---
name: memory-groom
description: Groom the memory vault at ~/memory - promote durable facts from Auto Memory/ into curated notes, prune what was promoted, flag contradictions, and audit note freshness. Use when the user says "groom memory", "promote auto memory", or on a scheduled groom run.
---

# Memory groom

One pass over the memory vault (`~/memory`; adjust if yours lives elsewhere) that
keeps raw capture from rotting: promote, prune, reconcile, audit, commit. Vault
conventions live in the vault's `README.md`; read it first.

Write carefully: update existing notes in place and reconcile with what is there.
A groom run never creates parallel copies of a fact; the curated note is the single
home, and the run moves facts into it.

## 1. Scope the run

Find the last groom commit and diff since it:

```bash
cd ~/memory
last=$(git log --grep '^Groom memory' -1 --format=%H)
git diff --name-only ${last:-$(git rev-list --max-parents=0 HEAD)} -- 'Auto Memory/'
```

No prior groom commit means the whole of `Auto Memory/` is in scope. Read every
in-scope file, plus `Atlas.md`, `Bearing.md`, and the index notes. `Daily/` is out of
scope for promotion; durable bits from a day are filed to `Auto Memory/` at capture
time by whatever writes the daily note.

## 2. Promote

Classify each captured fact with the storage rule from `README.md`: a fact must be
**timeless, dated, or a pointer**. Then route it:

- Behavior corrections and recurring gotchas → a note in `Memories/` (update an
  existing note covering the topic before creating one).
- Facts about a project, person, or decision → the matching curated note under its
  index; create the note if it does not exist. Project and person notes carry the
  sparse frontmatter from `README.md` (`type`, `status`/`repo` or `org`, `reviewed`);
  the index notes render Bases views over that frontmatter, so a correctly stamped
  note appears in its index with no index edit. A `decision-*.md` capture becomes its
  own note in `Decisions/`, Title Case filename, with `type: decision`, `date`,
  `project` (the project note's name, a list when two), and `reviewed` frontmatter;
  `Decisions.base` renders it under `Decisions Index.md`, so no index edit either.
- Fast-changing state → `Bearing.md`, or drop it if already stale.
- Noise (session-local detail, facts the repo or rules already record) → drop.
- `weekly-review-*.md` files: promote durable bits like any capture, keep the file
  in place as the week's record, and delete reviews older than four weeks.

A promoted fact keeps its substance, not its wording; distill. Add `[[wikilinks]]`
between the notes a fact connects.

## 3. Reconcile, never overwrite

A captured fact that contradicts a curated note is flagged, not resolved: add a line
under `## Watching` in `Bearing.md` naming both notes and the conflict. The curated
note stays as it is until a human (or an explicitly asked session) settles it.

## 4. Prune

Remove what step 2 promoted or dropped: delete the `Auto Memory/` file (or the
promoted lines from a multi-fact file) and its line in `Auto Memory/MEMORY.md`.
Every remaining index line must point at a file that still exists, and every
remaining file must hold only facts not yet worth promoting. Never read, promote
from, or delete anything under `Daily/`; it is a record, not capture.

## 5. Audit freshness

Across the curated notes (root notes and `Memories/`; `Auto Memory/` and `Daily/`
are exempt, and never get a `reviewed:` stamp):

- List notes whose `reviewed:` frontmatter date is more than 90 days old, or absent
  (`Review Queue.base` renders the same list inside Obsidian).
- Check frontmatter consistency: every project note has `type: project`, `status`,
  and `repo`; every person note has `type: person`. A note missing its `type` is
  invisible to the index views.
- Age out person notes' `## Running threads`: delete bullets the evidence shows
  resolved, and flag ones stale past 90 days under Watching instead of guessing.
- List dead wikilinks (`[[Target]]` with no `Target.md`) and orphans (curated notes
  no index or note links to).

Fix the mechanical ones (add missing index lines, correct obvious link typos). Add
anything needing judgment to `## Watching` in `Bearing.md`. Stamp `reviewed:` with
today's date on every curated note the run verified or updated.

## 6. Commit

One commit, subject starting `Groom memory:` followed by a one-line summary of what
moved (the `^Groom memory` grep in step 1 depends on this prefix). Push. The run is
done when `git status` is clean and the push succeeded.

---
name: weekly-review
description: Write a weekly review note into the memory vault from the week's Auto Memory capture, git and GitHub activity, and Radar - themes, stale projects, open decisions, progress. Use when the user says "weekly review" or on the scheduled weekly review run.
---

# Weekly review

One note that answers "what actually happened this week" from evidence, written into
`~/memory/Auto Memory/` as capture. The groom run consumes it like any
other capture: durable bits get promoted, and reviews older than four weeks get
deleted.

## 1. Gather the week

Window: the last 7 days.

- `Auto Memory/`: every file touched this week (`git log --since='7 days ago'
  --name-only -- 'Auto Memory/'`), including decision captures.
- Activity: for each vault note with `type: project` and `status: active`, use its
  `repo` field: `gh search prs --author @me --repo <owner/repo> --updated <start>..`
  and the `--reviewed-by @me` variant. Local clones under `your code directory` add
  `git log --all --since='7 days ago' --author=<user>` color when present.
- State: `Radar.md` (Active, Watching), the project notes' `## Now` and
  `## Open threads`, and `Review Queue.base`'s criteria (curated notes with
  `reviewed:` absent or older than 90 days).

## 2. Write the review

One file: `Auto Memory/weekly-review-YYYY-MM-DD.md` (dated the day it runs).

```markdown
---
type: weekly-review
date: YYYY-MM-DD
---

# Week of YYYY-MM-DD

## Themes
<2-4 bullets: what the week was actually about, named by PRs, tickets, notes.>

## Progress
<Radar Active items and project ## Now lines, each with what moved or "no movement".>

## Open decisions
<Watching items and unpromoted decision captures awaiting a call.>

## Stale
<Projects with no activity this week; curated notes past the review horizon.>
```

Distill; every line names a real thing. No pep talk, no filler sections when empty;
drop a heading rather than write "(nothing)".

## 3. Commit

Commit the vault with subject `Weekly review: <one-line theme>` and push. Writing
only into `Auto Memory/` keeps the run inside the free-write zone.

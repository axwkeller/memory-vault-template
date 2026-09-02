---
name: weekly-review
description: Write a weekly review note into the memory vault from the week's Auto Memory capture, git and GitHub activity, and Bearing, and score the week against Compass goals when a charter exists - themes, stale projects, open decisions, progress. Use when the user says "weekly review" or on the scheduled weekly review run.
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
- `Daily/`: the week's `Daily/YYYY-MM-DD.md` notes, the seven dates in the window
  (missing days are simply absent; say nothing about them). They feed Themes (the
  `## Work close` and `## Personal close` lines), Progress (the `Goal:` lines in
  personal closes), and Against Compass (the `Evidence:` lines, which already name
  a Call Me Out pattern heading and a fact, so the review needs no read of
  `Call Me Out.md` itself).
- Activity: for each vault note with `type: project` and `status: active`, use its
  `repo` field: `gh search prs --author @me --repo <owner/repo> --updated <start>..`
  and the `--reviewed-by @me` variant. Local clones under `your code directory` add
  `git log --all --since='7 days ago' --author=<user>` color when present.
- State: `Bearing.md` (Active, Watching), the project notes' `## Now` and
  `## Open threads`, and `Review Queue.base`'s criteria (curated notes with
  `reviewed:` absent or older than 90 days).
- Compass, read only: `~/compass/Goals.md` and `~/compass/How I Work.md`. If either
  file is missing, skip the Against Compass section below silently; do not error, do
  not note the absence.

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
<Bearing Active items and project ## Now lines, each with what moved or "no movement".>

## Open decisions
<Watching items and unpromoted decision captures awaiting a call.>

## Stale
<Projects with no activity this week; curated notes past the review horizon.>

## Against Compass
<one line per goal in Goals.md: the goal's name, then what moved this week or "no movement", naming the PR, ticket, or note.>
<one line per pattern in How I Work.md that the week's evidence shows, named and pointed at the evidence.>
<one line per Call Me Out pattern carried through from the week's `Evidence:` lines in `Daily/`, heading and fact only.>
```

Distill; every line names a real thing. No pep talk, no filler sections when empty;
drop a heading rather than write "(nothing)". Drop Against Compass entirely when
Compass is absent.

Name the goal or pattern; never quote Compass text into the note. The review lands in
`Auto Memory/`, and Compass content must not migrate into the vault through it.

The run never writes to Compass. Reading a run where a goal never moves is the signal
to open a `compass` session and change the goal or the plan by hand.

## 3. Commit

Commit the vault with subject `Weekly review: <one-line theme>` and push. Writing
only into `Auto Memory/` keeps the run inside the free-write zone.

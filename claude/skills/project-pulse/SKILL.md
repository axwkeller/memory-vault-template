---
name: project-pulse
description: Update the memory vault's active project notes from the last week of GitHub and Jira activity - current initiative, open threads, what got punted. Use when the user says "project pulse", "update the project notes", or on the scheduled weekly pulse run.
---

# Project pulse

One weekly pass that keeps the memory vault's project notes true. A project note
holds what the repo cannot tell a session: the current initiative, open threads with
teammates, what got punted and why, gotchas. This skill refreshes those from
evidence; it never pads a note with activity logs.

## 1. Find the projects

In `~/memory`, every root note with `type: project` and
`status: active` frontmatter is in scope; its `repo` field names the GitHub repo.
Read each note plus `Radar.md` before gathering.

## 2. Gather a week of evidence

Window: the last 7 days. Resolve identity at runtime, never hardcode
(`gh api user -q .login`).

GitHub, per repo:

- PRs authored: `gh search prs --author @me --repo <owner/repo> --updated <start>.. --json title,number,state,updatedAt`
- PRs reviewed: same with `--reviewed-by @me`.
- Open PRs awaiting the user's review or reply:
  `gh pr list --repo <owner/repo> --search "review-requested:@me"`.

Jira, only when the project uses it and auth is available:

- `jira issue list --jql 'assignee was currentUser() AND updated >= "<start>"' --plain`

Missing Jira auth degrades to GitHub-only; say so in the commit message rather than
failing.

## 3. Update each note in place

Reconcile with what is there; never append-only. Maintain three sections after the
note's intro, creating them on first pulse:

- `## Now`: the current initiative in one or two sentences, named by real tickets
  and PRs. Replace, do not stack.
- `## Open threads`: unresolved review threads, PRs waiting on someone, questions
  pending with a teammate ([[wikilink]] people who have notes). Remove threads the
  evidence shows closed.
- `## Punted`: what was deliberately deferred and why. Remove entries once done or
  irrelevant.

Hand-written bullets outside these sections are not the pulse's to edit. A finished
initiative worth keeping moves to `Decisions Index.md` territory via a
`decision-*.md` capture in `Auto Memory/`, not deletion into nothing. Stamp
`reviewed:` with today's date on every note updated.

## 4. Radar and commit

Sync `Radar.md`'s Active section with what the notes now say; flag contradictions
under `## Watching` instead of resolving them. One commit, subject starting
`Project pulse:` with a one-line summary, then push.

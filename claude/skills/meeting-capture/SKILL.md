---
name: meeting-capture
description: Capture a meeting or interaction into the memory vault's person and project notes, or prep for one by pulling a person's note and open threads. Use when the user shares meeting notes or a transcript to capture, says "capture this meeting", or asks to "prep for my meeting with <name>".
---

# Meeting capture

Two flows over the memory vault (`~/memory`): capture after a meeting,
prep before one. Person notes are the CRM; the wikilink graph does the rest.

## Person note shape

One root note per collaborator, filename their name, listed by `People.base` via
frontmatter:

```markdown
---
type: person
org: <company or team>
reviewed: YYYY-MM-DD
---

# <Name>

<What they own, how they like to work, how they like PRs split. Distilled, stable.>

## Running threads

- YYYY-MM-DD: <open item, question, or commitment, with [[project]] links>.
```

## Capture (after a meeting)

Input: pasted notes, a transcript, or the user's summary.

1. Extract only what changes future behavior: decisions made, action items with an
   owner, new facts about what someone owns or how they work. Drop pleasantries,
   scheduling, and anything already recorded.
2. Route each item:
   - Decisions → a `decision-YYYY-MM-DD-<slug>.md` capture in `Auto Memory/` per
     the decision-capture skill.
   - Action items and open questions → a dated bullet under `## Running threads`
     in each participant's person note; the user's own items also go to the
     relevant project note's `## Open threads`.
   - Durable facts about a person → the intro of their person note, reconciled
     with what is there.
3. Create missing person notes with the shape above; `People.base` picks them up
   from frontmatter, no index edit needed. Wikilink people and projects both ways.
4. Stamp `reviewed:` on every note touched, then commit the vault
   (`Meeting capture: <who/what>`) and push.

Editing person notes directly is fine here: this skill only runs on an explicit
request, which is what the write-zone hook exists to confirm.

## Prep (before a meeting)

Given a name, output a brief to the user; write nothing.

1. Read the person's note; say if none exists and offer to create one after the
   call.
2. Collect their open items: `## Running threads` bullets, mentions of them in
   project notes' `## Open threads`, and open GitHub PRs between the user and them
   (`gh search prs --repo <repo> --author <them> --review-requested @me` and the
   reverse) for repos in [[Projects Index]].
3. Present: who they are (one line), open threads oldest first, and anything under
   Bearing's Watching that names them.

## Groom interplay

Old `## Running threads` bullets are the groom run's to age out: resolved or stale
threads get pruned there, not stacked forever. The groom's frontmatter audit covers
person notes (`type: person`, `org`).

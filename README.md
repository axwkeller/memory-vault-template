# Memory vault template

An Obsidian vault that serves as persistent, git-synced memory for Claude Code.
Claude reads it at session start, writes raw capture to `Auto Memory/`, and a groom
run, driven by hand, promotes durable facts into curated notes.

The design follows a few rules that keep agent memory from rotting:

- **Layered memory with promotion.** Raw capture (`Auto Memory/`) is quarantined
  from curated notes; a groom pass moves durable facts up and prunes the rest.
- **Timeless, dated, or a pointer.** Every stored fact is slow knowledge, carries
  its date, or links to the live source. Fast-changing data is never copied in.
- **Write zones, enforced.** Sessions write freely to `Auto Memory/` and `Daily/`;
  curated notes change only through the groom run or an explicit request, gated by
  a hook.
- **Indexes over folders.** Flat root, Title Case filenames, `[[wikilinks]]`, and
  index notes as the agent's entry points.

## Conventions

- Flat root, Title Case filenames, `[[wikilinks]]`, index notes instead of folders.
  Four folders hold Claude-written files: `Memories/` and `Decisions/` (curated, the
  latter one note per decision), `Auto Memory/` (raw capture), and `Daily/` (one note
  per day, a record). Records are kept as written: never promoted, pruned, or stamped
  `reviewed`.
- Write distilled facts, not transcripts. A note earns its place by changing how a
  future session behaves.
- Every stored fact is **timeless, dated, or a pointer**: slow knowledge is stored
  directly; anything time-bound carries its date; fast-changing data is a link to
  the live source with a timestamp, never a copy.
- Frontmatter stays sparse: `reviewed` everywhere, `type` on content notes
  (`project` | `person` | `decision` | `memory` | `daily`), `status` and `repo` on
  projects, `org` on people, `date` and `project` on decisions, `date` on dailies. The index notes and [[Bearing]] embed Bases
  views (`Projects.base`, `People.base`, `Decisions.base`, `Review Queue.base`) over
  those fields; update the frontmatter, never the tables.
- A `Memories/` note scoped to one repo (a boy-scout rule, a project-only habit)
  carries `repo: <owner>/<name>` frontmatter matching the project note. The
  `session-bearing.sh` hook injects it only in sessions whose cwd's git origin
  matches, alongside Bearing; a `Memories/` note with no `repo:` field stays global
  and loads only when a session reads it deliberately. `Memory By Repo.base` groups
  every note carrying a `repo:` field (project notes and scoped memory notes alike)
  for browsing one project's memory in one place.
- Curated notes (root notes, `Memories/`, and `Decisions/`) carry a `reviewed:` frontmatter date,
  stamped whenever a session verifies or updates the note. The groom run promotes
  from `Auto Memory/`, prunes, and (on its weekly pass) audits notes past a 90-day
  review horizon; contradictions and judgment calls land under Watching in
  [[Bearing]].
- Sessions write freely to `Auto Memory/` and `Daily/`; curated notes change through
  the groom run, gated by a `.groom` marker at the vault root, or an explicit
  request (a hook enforces this).
- After updating this vault, commit and push.

## Layout

| Path | Purpose |
| --- | --- |
| `Atlas.md` | Map of the vault; read first every session |
| `Bearing.md` | What is active right now; the note that changes most |
| `Projects Index.md`, `People Index.md`, `Decisions Index.md` | Curated indexes; one child note per project, person, decision |
| `Projects.base`, `People.base`, `Decisions.base`, `Review Queue.base` | Bases views the indexes and Bearing embed; they render from note frontmatter (`type`, `status`, `repo`, `org`, `date`, `reviewed`), so there are no hand-edited index tables. Needs Obsidian 1.9+ with the Bases core plugin |
| `Memory By Repo.base` | Bases view grouping every note with a `repo:` field, project notes and repo-scoped `Memories/` notes alike |
| `Memories/` | Agent-written memory notes (behavior corrections, recurring gotchas); `type: memory`, plus `repo:` when scoped to one repo |
| `Decisions/` | One note per decision: `type: decision`, `date`, `project` (the project note's name), `reviewed`; `Decisions.base` renders them under `Decisions Index.md` |
| `Auto Memory/` | Raw machine capture from Claude Code's auto-memory; promoted and pruned by the groom run |
| `Daily/` | One note per day (`type: daily`, `date`), a record the weekly review reads and the groom never touches; shape under Daily notes below |
| `claude/` | The skills and hooks to install into your Claude Code config |

## Setup

Prerequisites: Claude Code, git, and (optionally) Obsidian pointed at the vault.

1. Create your vault from this template and clone it:

   ```bash
   gh repo create my-memory --template <this-repo> --private --clone
   ```

2. Fill in `Atlas.md` (the `<...>` placeholders) and point Claude Code's auto-memory
   at the vault in `~/.claude/settings.json`:

   ```json
   {
     "autoMemoryEnabled": true,
     "autoMemoryDirectory": "<vault path>/Auto Memory"
   }
   ```

3. Tell Claude about the vault in `~/.claude/CLAUDE.md`:

   ```markdown
   ## Memory
   The Obsidian vault at <vault path> is the single source of truth for durable
   memory about me. Read Atlas.md and Bearing.md there when context calls for it.
   At the end of a piece of work, capture any durable decision (chose X over Y
   because Z) into the vault's Auto Memory/ per the decision-capture skill.
   After updating it, commit and push.
   ```

4. Install the skills and the write-zone hook:

   ```bash
   cp -R claude/skills/bod claude/skills/memory-groom claude/skills/decision-capture claude/skills/project-pulse claude/skills/meeting-capture claude/skills/weekly-review ~/.claude/skills/
   cp claude/hooks/memory-write-zones.sh claude/hooks/session-bearing.sh ~/.claude/hooks/
   ```

   Set `VAULT` in both hooks to your vault path, then register them in
   `~/.claude/settings.json`. The write-zone hook confirms curated-note edits and
   passes them while a `.groom` marker at the vault root is fresh; the
   session-bearing hook injects `Bearing.md` at session start, plus any `Memories/`
   note whose `repo:` matches the session's git origin, so sessions actually read
   the vault:

   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Edit|Write|MultiEdit|NotebookEdit",
           "hooks": [
             { "type": "command", "command": "$HOME/.claude/hooks/memory-write-zones.sh" }
           ]
         }
       ],
       "SessionStart": [
         {
           "matcher": "startup|resume|clear",
           "hooks": [
             { "type": "command", "command": "$HOME/.claude/hooks/session-bearing.sh" }
           ]
         }
       ]
     }
   }
   ```

5. Add the official Obsidian agent skills (wikilinks, Bases, web capture) from
   [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) to
   `~/.claude/skills/`. If you keep daily notes, point Obsidian's Daily notes core
   plugin at `Daily/` with the `YYYY-MM-DD` format.

## Running the rituals

Nothing runs unattended; every ritual is a slash command typed at a vault session, so
each run is watched as it happens.

- **`/bod`, every morning**: grooms yesterday's `Auto Memory/` capture with the
  `daily` scope (steps 1 to 4, then 6, no freshness audit) and reports what's open,
  no planning.
- **The Monday chain, by hand**: `/project-pulse`, then `/weekly-review`, then
  `/memory-groom` (bare, the full pass with the freshness audit). Run them in that
  order from a vault session so the review reads refreshed project notes and the
  groom promotes and prunes last.

A groom run touches `~/memory/.groom` before its first curated edit and removes it
once the change is confirmed or reverted; the write-zone hook passes curated edits
while that marker is under three hours old, so the whole diff is built before anyone
is asked to confirm it. `MEMORY_GROOM=1` is the separate bypass for a headless run
with nobody at the prompt to answer the hook, for example a one-off `claude -p`
invocation:

```bash
MEMORY_GROOM=1 claude -p "/memory-groom" --permission-mode acceptEdits
```

## Day to day

Nothing here requires remembering to do anything beyond running `/bod` and the
Monday chain; the phrases below are the manual levers underneath them.

- **Automatic, every session:** `Bearing.md` is injected at session start, along with
  any memory note scoped to the repo the session is in; auto-memory
  captures raw facts to `Auto Memory/`. Ask Claude to "remember" something and it
  lands in `Auto Memory/` as well.
- **"bod"**: groom yesterday's capture (`daily` scope) and report what's open.
- **"capture decisions"**: log this session's durable choices (chose X over Y
  because Z) as `Auto Memory/decision-*.md` files.
- **"capture this meeting"** (with notes or a transcript pasted): file decisions and
  action items into the person and project notes.
- **"prep for my meeting with X"**: read-only brief from X's person note, open
  threads, and open PRs between you.
- **"project pulse"**: refresh active project notes' Now / Open threads / Punted
  from the last week of GitHub activity (plus Jira where configured).
- **"weekly review"**: write the week's themes/progress/stale note into
  `Auto Memory/`, scored against Compass when you keep a charter.
- **"groom memory"**: promote from `Auto Memory/` into curated notes, prune, and,
  bare or with the `weekly` scope, audit freshness.
- **Daily notes** under `Daily/` are yours to write however suits you; the weekly
  review reads whatever the week holds.
- **Editing curated notes by hand** is always fine; the write-zone hook asks once to
  confirm the edit was wanted. In Obsidian, just edit; the index tables update
  themselves from frontmatter, so never hand-edit a table.

## Cadence

- **Morning**: run `/bod` from a vault session. It grooms yesterday's capture and
  reports what's open; nothing else runs on its own.
- **During the day**: sessions read Bearing on start. Say "capture decisions" at the
  end of a piece of work and "capture this meeting" with notes pasted.
- **Evening**: write today's `Daily/` note, by hand or with an end-of-day skill of
  your own, then commit and push.
- **Monday, or whenever the week's notes should land**: run the chain by hand,
  `/project-pulse`, `/weekly-review`, `/memory-groom`. Read the new
  `Auto Memory/weekly-review-*.md`, then the groom commit
  (`git log --grep '^Groom memory' -1 -p`). Anything the groom would not decide alone
  sits under Watching in `Bearing.md`.

## Daily notes

`Daily/` is a record, not capture: one note per day, kept forever, never promoted,
pruned, or stamped. Write them by hand in Obsidian or with an end-of-day skill of
your own; the weekly review reads the week's notes and says nothing about missing
days. The shape it reads:

```markdown
---
type: daily
date: YYYY-MM-DD
---

## Plan

## Journal

## Work close

## Personal close
```

Entries are `HH:MM <text>` lines appended under a section, never rewritten; the two
close sections feed the review's Themes. With a Compass charter (below), two more
line forms name its headings: `HH:MM Goal: <Goals.md heading>: done | moved |
untouched` feeds Progress, and `HH:MM Evidence: <Call Me Out heading>: <fact>` feeds
Against Compass. Durable facts from a day go to `Auto Memory/` when they are
written, since the groom never reads `Daily/`.

## The weekly cycle

Run the three commands in order and each stage feeds the next: the pulse refreshes
project notes, the review writes `Auto Memory/weekly-review-*.md` from the refreshed
notes and the week's capture, and the groom promotes durable capture into curated
notes, prunes, audits freshness, commits, and pushes.

The morning after: skim the weekly review note in `Auto Memory/`, then the groom's
commit (`git log --grep '^Groom memory' -1 -p`). Anything the run would not decide
alone sits under Watching in `Bearing.md`; settle it by editing the curated note and
removing the flag. Git is the audit trail, and a bad promotion is a `git revert`
away.

## Compass, the companion charter

Memory answers "what happened"; a charter answers "was that the week I wanted." The
optional companion vault,
[compass-vault-template](https://github.com/axwkeller/compass-vault-template), holds
who you are, your goals with horizons, how you work, and the patterns you want called
out, in its own repo behind a hook that denies writes outside an edit session and
denies reads from work-org checkouts. It is a separate repo because `MEMORY_GROOM=1`
bypasses this vault's write-zone hook vault-wide, and because this vault may be
mirrored or shared while a charter never is.

With one present, the weekly review reads `Goals.md` and `How I Work.md` by name and
adds an `Against Compass` section: one line per goal (moved or no movement), one line
per pattern the week's evidence shows, and the daily notes' `Evidence:` lines carried
through. It names headings and never quotes charter text into this vault, and it
never writes to Compass; a goal that never moves across a few reviews is the signal to
open a charter session and change the goal or the plan by hand. Without one, the
review writes its original four sections and says nothing about the absence.

## Keeping it healthy

- Keep `Atlas.md` and `Bearing.md` short. Every line there is read every session;
  growth belongs in linked child notes.
- A note earns its place by changing how a future session behaves; distilled facts,
  not transcripts.
- Trust the review horizon: `Review Queue.base` (embedded in `Bearing.md`) surfaces
  notes past 90 days, and the groom works that list.
- Records stay records. `Daily/` is never groomed, so a durable fact from a day has
  to be filed into `Auto Memory/` when it is written, or it never reaches a curated
  note.

# Memory vault template

An Obsidian vault that serves as persistent, git-synced memory for Claude Code.
Claude reads it at session start, writes raw capture to `Auto Memory/`, and a
scheduled groom run promotes durable facts into curated notes.

The design follows a few rules that keep agent memory from rotting:

- **Layered memory with promotion.** Raw capture (`Auto Memory/`) is quarantined
  from curated notes; a groom pass moves durable facts up and prunes the rest.
- **Timeless, dated, or a pointer.** Every stored fact is slow knowledge, carries
  its date, or links to the live source. Fast-changing data is never copied in.
- **Write zones, enforced.** Sessions write freely to `Auto Memory/`; curated notes
  change only through the groom run or an explicit request, gated by a hook.
- **Indexes over folders.** Flat root, Title Case filenames, `[[wikilinks]]`, and
  index notes as the agent's entry points.

## Layout

| Path | Purpose |
| --- | --- |
| `Home.md` | Entry point and vault contract; read first every session |
| `Radar.md` | What is active right now; the note that changes most |
| `Projects Index.md`, `People Index.md`, `Decisions Index.md` | Curated indexes; one child note per project, person, decision |
| `Projects.base`, `People.base`, `Decisions.base`, `Review Queue.base` | Bases views the indexes and Radar embed; they render from note frontmatter (`type`, `status`, `repo`, `org`, `date`, `reviewed`), so there are no hand-edited index tables. Needs Obsidian 1.9+ with the Bases core plugin |
| `Memories/` | Agent-written memory notes (behavior corrections, recurring gotchas) |
| `Auto Memory/` | Raw machine capture from Claude Code's auto-memory; promoted and pruned by the groom run |
| `claude/` | The skill and hook to install into your Claude Code config |

## Setup

Prerequisites: Claude Code, git, and (optionally) Obsidian pointed at the vault.

1. Create your vault from this template and clone it:

   ```bash
   gh repo create my-memory --template <this-repo> --private --clone
   ```

2. Fill in `Home.md` (the `<...>` placeholders) and point Claude Code's auto-memory
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
   memory about me. Read Home.md and Radar.md there when context calls for it.
   At the end of a piece of work, capture any durable decision (chose X over Y
   because Z) into the vault's Auto Memory/ per the decision-capture skill.
   After updating it, commit and push.
   ```

4. Install the skills and the write-zone hook:

   ```bash
   cp -R claude/skills/memory-groom claude/skills/decision-capture claude/skills/project-pulse claude/skills/meeting-capture claude/skills/weekly-review ~/.claude/skills/
   cp claude/hooks/memory-write-zones.sh claude/hooks/session-radar.sh ~/.claude/hooks/
   ```

   Set `VAULT` in both hooks to your vault path, then register them in
   `~/.claude/settings.json`. The write-zone hook confirms curated-note edits; the
   session-radar hook injects `Radar.md` at session start so sessions actually read
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
             { "type": "command", "command": "$HOME/.claude/hooks/session-radar.sh" }
           ]
         }
       ]
     }
   }
   ```

5. Add the official Obsidian agent skills (wikilinks, Bases, web capture) from
   [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) to
   `~/.claude/skills/`.

## Scheduling the groom run

Run the groom weekly so promotion happens without you. Any scheduler works; the
job is one headless command:

```bash
MEMORY_GROOM=1 claude -p "/memory-groom" --permission-mode acceptEdits
```

`MEMORY_GROOM=1` lets the run pass the write-zone hook, since nobody is at the
prompt to answer it. With cron:

```cron
17 20 * * 0 cd <vault path> && MEMORY_GROOM=1 claude -p "/memory-groom" --permission-mode acceptEdits >> ~/memory-groom.log 2>&1
```

The optional project pulse and weekly review run the same way, staggered before the
groom so the pulse refreshes project notes, the review reads them and the week's
capture, and the groom promotes and prunes last:

```cron
30 19 * * 0 cd <vault path> && MEMORY_GROOM=1 claude -p "/project-pulse" --permission-mode acceptEdits >> ~/project-pulse.log 2>&1
0 20 * * 0 cd <vault path> && MEMORY_GROOM=1 claude -p "/weekly-review" --permission-mode acceptEdits >> ~/weekly-review.log 2>&1
```

On macOS, a LaunchAgent with a `StartCalendarInterval` wrapping the same command
survives sleep better than cron.

## Day to day

Nothing here requires remembering to do anything; the phrases below are the manual
levers on top of what runs by itself.

- **Automatic, every session:** `Radar.md` is injected at session start; auto-memory
  captures raw facts to `Auto Memory/`; the session-end habit captures durable
  decisions there too. Ask Claude to "remember" something and it lands in
  `Auto Memory/` as well.
- **"capture decisions"**: log this session's durable choices (chose X over Y
  because Z) as `Auto Memory/decision-*.md` files.
- **"capture this meeting"** (with notes or a transcript pasted): file decisions and
  action items into the person and project notes.
- **"prep for my meeting with X"**: read-only brief from X's person note, open
  threads, and open PRs between you.
- **"project pulse"**: refresh active project notes' Now / Open threads / Punted
  from the last week of GitHub activity (plus Jira where configured).
- **"weekly review"**: write the week's themes/progress/stale note into
  `Auto Memory/`.
- **"groom memory"**: promote from `Auto Memory/` into curated notes, prune, audit
  freshness.
- **Editing curated notes by hand** is always fine; the write-zone hook asks once to
  confirm the edit was wanted. In Obsidian, just edit; the index tables update
  themselves from frontmatter, so never hand-edit a table.

## The weekly cycle

With the three jobs scheduled as above, each stage feeds the next: the pulse
refreshes project notes, the review writes `Auto Memory/weekly-review-*.md` from the
refreshed notes and the week's capture, and the groom promotes durable capture into
curated notes, prunes, audits freshness, commits, and pushes.

The morning after: skim the weekly review note in `Auto Memory/`, then the groom's
commit (`git log --grep '^Groom memory' -1 -p`). Anything the run would not decide
alone sits under Watching in `Radar.md`; settle it by editing the curated note and
removing the flag. Git is the audit trail, and a bad promotion is a `git revert`
away.

## Keeping it healthy

- Keep `Home.md` and `Radar.md` short. Every line there is read every session;
  growth belongs in linked child notes.
- A note earns its place by changing how a future session behaves; distilled facts,
  not transcripts.
- Trust the review horizon: `Review Queue.base` (embedded in `Radar.md`) surfaces
  notes past 90 days, and the groom works that list.

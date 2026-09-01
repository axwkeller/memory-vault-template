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
   After updating it, commit and push.
   ```

4. Install the groom skill and the write-zone hook:

   ```bash
   cp -R claude/skills/memory-groom ~/.claude/skills/
   cp claude/hooks/memory-write-zones.sh ~/.claude/hooks/
   ```

   Set `VAULT` in the hook to your vault path, then register it in
   `~/.claude/settings.json`:

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

On macOS, a LaunchAgent with a `StartCalendarInterval` wrapping the same command
survives sleep better than cron.

## Day to day

- Sessions capture facts to `Auto Memory/` automatically; ask Claude to "remember"
  something and it lands there too.
- Say "groom memory" to run a promotion pass by hand.
- Review groom commits like any other diff; git is the audit trail and the undo.
- Keep `Home.md` and `Radar.md` short. Every line there is read every session;
  growth belongs in linked child notes.

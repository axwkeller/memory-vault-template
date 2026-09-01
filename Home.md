# Home

Entry point for the memory vault. This vault is the single source of truth for what
Claude should remember about <your name> across sessions and machines. Read this note
and [[Radar]] at the start of a session; follow links deeper only when the work calls
for it.

## Who

<Your name> (<email>, GitHub: <handle>). <Role and primary project.> <Machine and
where code lives.>

## Map

- [[Radar]]: what is active right now. The note that changes most.
- [[Projects Index]]: one note per project worth remembering.
- [[People Index]]: collaborators and how <your name> works with them.
- [[Decisions Index]]: durable choices and the reasons behind them.
- `Memories/`: Claude-written memory notes (behavior corrections, recurring gotchas).
- `Auto Memory/`: machine-written memory from Claude Code (`autoMemoryDirectory`
  points here). Raw capture; the groom run promotes anything durable into
  `Memories/` or the curated notes above and prunes the rest.

## Conventions

- Flat root, Title Case filenames, `[[wikilinks]]`, index notes instead of folders.
  Two folders quarantine Claude-written files: `Memories/` (curated) and
  `Auto Memory/` (raw capture).
- Write distilled facts, not transcripts. A note earns its place by changing how a
  future session behaves.
- Every stored fact is **timeless, dated, or a pointer**: slow knowledge is stored
  directly; anything time-bound carries its date; fast-changing data is a link to
  the live source with a timestamp, never a copy.
- Curated notes (root notes and `Memories/`) carry a `reviewed:` frontmatter date,
  stamped whenever a session verifies or updates the note. The scheduled groom run
  promotes from `Auto Memory/`, prunes, and audits notes past a 90-day review
  horizon; contradictions and judgment calls land under Watching in [[Radar]].
- Sessions write freely to `Auto Memory/`; curated notes change through the groom
  run or an explicit request (a hook enforces this).
- After updating this vault, commit and push.

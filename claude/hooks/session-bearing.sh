#!/usr/bin/env bash
# SessionStart hook: inject the memory vault's Bearing note so every session starts
# knowing what is active. Bearing.md stays tiny by convention; growth belongs in
# linked leaf notes, so the token cost here stays flat.
#
# Also injects any curated note whose `repo:` frontmatter matches the current
# repo's origin (owner/repo), so project-scoped memory (e.g. a boy-scout rule
# that only makes sense in one repo) loads there and nowhere else, without
# relying on Claude to think to go read it.
set -uo pipefail

VAULT="$HOME/memory"
BEARING="$VAULT/Bearing.md"

# Headless vault jobs (groom, pulse, review) read the vault themselves.
if [[ "${MEMORY_GROOM:-}" == "1" ]]; then
  exit 0
fi

if [[ ! -f "$BEARING" ]]; then
  exit 0
fi

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')

repo=""
if [[ -n "$cwd" ]]; then
  origin=$(git -C "$cwd" remote get-url origin 2>/dev/null || true)
  repo=$(printf '%s' "$origin" | sed -E 's#^git@[^:]+:##; s#^https?://[^/]+/##; s#\.git$##')
fi

scoped=""
if [[ -n "$repo" ]]; then
  while IFS= read -r -d '' f; do
    frontmatter=$(sed -n '2,/^---$/p' "$f" | sed '$d')
    if printf '%s\n' "$frontmatter" | grep -qxF "repo: $repo"; then
      scoped+=$'\n\n---\n\n'"$(cat "$f")"
    fi
  done < <(find "$VAULT" -maxdepth 2 -name '*.md' -not -path "$VAULT/Auto Memory/*" -print0)
fi

jq -n --rawfile bearing "$BEARING" --arg scoped "$scoped" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Memory vault Bearing (Bearing.md, read Atlas.md there for the full map):\n\n" + $bearing
      + (if $scoped != "" then "\n\nNotes scoped to this repo:" + $scoped else "" end))
  }
}'

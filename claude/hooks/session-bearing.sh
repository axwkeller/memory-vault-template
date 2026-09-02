#!/usr/bin/env bash
# SessionStart hook: inject the memory vault's Bearing note so every session starts
# knowing what is active. Bearing.md stays tiny by convention; growth belongs in
# linked leaf notes, so the token cost here stays flat.
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

jq -n --rawfile bearing "$BEARING" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Memory vault Bearing (Bearing.md, read Atlas.md there for the full map):\n\n" + $bearing)
  }
}'

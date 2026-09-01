#!/usr/bin/env bash
# SessionStart hook: inject the memory vault's Radar note so every session starts
# knowing what is active. Radar.md stays tiny by convention; growth belongs in
# linked leaf notes, so the token cost here stays flat.
set -uo pipefail

VAULT="$HOME/memory"
RADAR="$VAULT/Radar.md"

# Headless vault jobs (groom, pulse, review) read the vault themselves.
if [[ "${MEMORY_GROOM:-}" == "1" ]]; then
  exit 0
fi

if [[ ! -f "$RADAR" ]]; then
  exit 0
fi

jq -n --rawfile radar "$RADAR" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Memory vault Radar (Radar.md, read Home.md there for the full map):\n\n" + $radar)
  }
}'

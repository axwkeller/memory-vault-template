#!/usr/bin/env bash
# Enforces the memory vault's write zones, so the convention in README.md is a gate
# rather than a hope: sessions write freely to `Auto Memory/` and `Daily/`, and
# edits to curated notes reach a human as a question. The memory-groom skill is the
# sanctioned path for curated edits: it touches `.groom` at the vault root before
# its first edit and removes it once the diff is confirmed or reverted, and the
# hook passes while that marker is under three hours old. A headless run with
# nobody at the prompt sets MEMORY_GROOM=1 instead.
#
# Every decision here is `ask`, never `deny`. A wrong guess costs one keystroke.
set -uo pipefail

if [ -n "${MEMORY_GROOM:-}" ]; then exit 0; fi

VAULT="$HOME/memory"

# A fresh marker is a groom building the diff the user will confirm as a whole. One
# older than three hours is a run that never finished, and passes nothing.
if [ -n "$(find "$VAULT/.groom" -maxdepth 0 -mmin -180 2>/dev/null)" ]; then exit 0; fi

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
case "$file_path" in
  "$VAULT"/*) ;;
  *) exit 0 ;;
esac

# A literal `..` or `.` segment can walk a free-write prefix match out of its
# zone (e.g. `Daily/../Bearing.md`); the target may not exist yet, so this
# can't be resolved with realpath. Send it to the ask branch instead of
# trusting the prefix.
case "$file_path" in
  */../*|*/./*|*/..|*/.) ;;
  "$VAULT/Auto Memory/"*) exit 0 ;;
  "$VAULT/Daily/"*) exit 0 ;;
esac

jq -nc --arg reason "This edits a curated memory note. README.md routes these through the memory-groom skill or an explicit request; confirm it was wanted." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
exit 0

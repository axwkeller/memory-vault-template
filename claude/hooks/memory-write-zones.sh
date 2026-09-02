#!/usr/bin/env bash
# Enforces the memory vault's write zones, so the convention in README.md is a gate
# rather than a hope: sessions write freely to `Auto Memory/`, and edits to curated
# notes reach a human as a question. The memory-groom skill is the sanctioned path
# for curated edits; its scheduled runs set MEMORY_GROOM=1 and pass through.
#
# Every decision here is `ask`, never `deny`. A wrong guess costs one keystroke.
set -uo pipefail

if [ -n "${MEMORY_GROOM:-}" ]; then exit 0; fi

VAULT="$HOME/memory"

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
case "$file_path" in
  "$VAULT"/*) ;;
  *) exit 0 ;;
esac

case "$file_path" in
  "$VAULT/Auto Memory/"*) exit 0 ;;
esac

jq -nc --arg reason "This edits a curated memory note. README.md routes these through the memory-groom skill or an explicit request; confirm it was wanted." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
exit 0

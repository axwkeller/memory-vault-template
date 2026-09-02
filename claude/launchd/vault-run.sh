#!/usr/bin/env bash
# Runs the vault's scheduled jobs once a day, at the first moment after FLOOR_HOUR
# that finds the machine awake and online. Schedule it at FLOOR_HOUR and again every
# 15 minutes (a LaunchAgent carries both; cron uses the tick alone): the stamp file
# makes every later tick a no-op, and a laptop that slept through the hour runs it at
# the next wake instead of skipping the day. On RUN_DAY it runs the project pulse,
# the weekly review, and the memory groom in that order, so the review reads
# refreshed project notes and the groom runs last.
set -uo pipefail

VAULT="<vault path>"
RUN_DAY=1 # 1 is Monday, 7 is Sunday
FLOOR_HOUR=4
STATE="$HOME/.local/state/vault-run"
LOGS="$STATE/logs"

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
export MEMORY_GROOM=1

today="$(date +%F)"
weekday="$(date +%u)"

[ "$((10#$(date +%H)))" -ge "$FLOOR_HOUR" ] || exit 0
[ -f "$STATE/last-run-day" ] && [ "$(cat "$STATE/last-run-day")" = "$today" ] && exit 0

# A fire right after wake can land before the network is back. Give it two minutes
# and, if it never comes, leave the stamp alone so the next tick tries again.
online=0
for _ in $(seq 1 12); do
  if curl -fs -m 5 -o /dev/null https://api.github.com/ 2>/dev/null; then
    online=1
    break
  fi
  sleep 10
done
[ "$online" -eq 1 ] || exit 0

# From here the day counts as run, whatever happens next: a failed run waits for
# tomorrow, or for a manual rerun after removing the stamp, rather than retrying
# every tick against a fault that needs a person.
mkdir -p "$LOGS" && printf '%s\n' "$today" > "$STATE/last-run-day"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

# Runs one skill headlessly, then pushes any commit it left behind: a stage can exit 0
# with its push refused, and the next stage should start from a pushed vault.
stage() {
  local name="$1" code=0
  log "start $name"
  (cd "$VAULT" && claude -p "/$name" --permission-mode acceptEdits) >> "$LOGS/$name.log" 2>&1 || code=$?
  if [ "$code" -eq 0 ]; then
    log "done $name"
  else
    log "WARN $name exited $code"
  fi
  if [ -n "$(git -C "$VAULT" log --oneline '@{upstream}..HEAD' 2>/dev/null)" ]; then
    log "$name left unpushed commits; pushing"
    git -C "$VAULT" push >> "$LOGS/$name.log" 2>&1 || log "WARN push after $name failed; see $name.log"
  fi
}

log "vault run for $today"
# Stages that run every day go here, one `stage <skill>` per line.
if [ "$weekday" -eq "$RUN_DAY" ]; then
  stage project-pulse
  stage weekly-review
  stage memory-groom
fi
log "vault run finished"

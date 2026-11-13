#!/bin/zsh
# Tracker: worktrees, branch state, plan.md presence. Refresh every 15s.
REPO="${1:-$PWD}"
while true; do
  out=$(
    echo "TRACKER · $(basename $REPO) · $(date +%H:%M:%S)"
    echo "────────────────────────────────────────"
    git -C "$REPO" worktree list --porcelain | awk '/^worktree /{print $2}' | while read wt; do
      br=$(git -C "$wt" branch --show-current 2>/dev/null)
      dirty=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      ab=$(git -C "$wt" rev-list --left-right --count origin/main...HEAD 2>/dev/null | awk '{print "↓"$1" ↑"$2}')
      last=$(git -C "$wt" log -1 --format='%cr · %s' 2>/dev/null | cut -c1-60)
      if [ -f "$wt/.flow/plan.md" ]; then plan=$(awk -F': *' '/^Status:/{print "["$2"]";exit}' "$wt/.flow/plan.md"); else plan="[no plan]"; fi
      [ -f "$wt/.flow/review.md" ] && plan="$plan $(awk -F': *' '/^Verdict:/{print "review:"$2;exit}' "$wt/.flow/review.md")"
      printf "● %-34s %s  %s files  %s\n    %s\n" "${br:-detached}" "$ab" "$dirty" "$plan" "$last"
    done
  )
  clear; print -r -- "$out"
  sleep 15
done

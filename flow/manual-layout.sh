#!/bin/zsh
# Open the 4-pane coding flow layout in Orca for one worktree.
#   ┌ lead · claude ─────────┬ builder-1 · codex ─────────┐
#   ├ tracker ───────────────┼ builder-2 · codex ─────────┤
# Usage: manual-layout.sh [worktree-path] [tab-title]
set -euo pipefail
WT="${1:-$PWD}"; WT="${WT:A}"
TITLE="${2:-Coding Flow · $(basename "$WT")}"
FLOW="$HOME/.orca/flow"
h() { python3 -c 'import json, sys
try:
    d = json.load(sys.stdin)
    if not isinstance(d, dict) or d.get("ok") is False: raise ValueError("Orca refused the command")
    def handles(v):
        if isinstance(v, dict):
            for k, x in v.items():
                if k == "handle" and isinstance(x, str) and x.strip(): yield x
                else: yield from handles(x)
        elif isinstance(v, list):
            for x in v: yield from handles(x)
    found = set(handles(d))
    if len(found) != 1: raise ValueError("Expected one Orca terminal handle")
    print(found.pop())
except (ValueError, TypeError) as e:
    sys.exit(str(e))'; }

LEAD=$(orca terminal create --worktree "path:$WT" --title "$TITLE" --command "claude" --json | h)
B1=$(orca terminal split --terminal "$LEAD" --direction vertical   --command "codex" --json | h)
B2=$(orca terminal split --terminal "$B1"   --direction horizontal --command "codex" --json | h)
TR=$(orca terminal split --terminal "$LEAD" --direction horizontal --command "${(q)FLOW}/track.sh ${(q)WT}" --json | h)

orca terminal set-pane-title --terminal "$LEAD" --title "lead · claude (manual)" >/dev/null
orca terminal set-pane-title --terminal "$B1"   --title "builder-1 · codex (task chính)" >/dev/null
orca terminal set-pane-title --terminal "$B2"   --title "builder-2 · codex (hàng phụ)" >/dev/null
orca terminal set-pane-title --terminal "$TR"   --title "tracker" >/dev/null
echo "lead=$LEAD builder1=$B1 builder2=$B2 tracker=$TR"

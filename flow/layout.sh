#!/bin/zsh
# Usage: layout.sh [worktree-path] [tab-title]
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
LEAD=$(orca terminal create --worktree "path:$WT" --title "$TITLE" \
  --command "claude --model claude-opus-5-5 --effort high --append-system-prompt-file ${(q)FLOW}/coordinator.md" --json | h)
TR=$(orca terminal split --terminal "$LEAD" --direction horizontal \
  --command "${(q)FLOW}/track.sh ${(q)WT}" --json | h)
orca terminal set-pane-title --terminal "$LEAD" --title "lead · Claude Opus 5.5 high" >/dev/null
orca terminal set-pane-title --terminal "$TR" --title tracker >/dev/null
print -r -- "lead=$LEAD tracker=$TR"

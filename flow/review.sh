#!/bin/zsh
# Manual helper: use only after the user approved this review round.
# Usage: review.sh worktree-path round-or-request.md
# Example: review.sh /path/to/worktree .flow/task/review-request-r2.md
set -euo pipefail
[[ $# == 2 ]] || { print -u2 -- "Usage: review.sh worktree-path round-or-request.md (ask user before each review)"; exit 1; }
WT="$1"; WT="${WT:A}"
if [[ "$2" == <-> ]]; then
  REQ="$WT/.flow/review-request-r$2.md"
elif [[ "$2" == *.md ]]; then
  if [[ "$2" == /* ]]; then REQ="$2"; else REQ="$WT/$2"; fi
else
  print -u2 -- "Expected a numeric round or an explicit .md request path"; exit 1
fi
REQ="${REQ:A}"
[[ -f "$REQ" && -r "$REQ" ]] || { print -u2 -- "No readable review request: $REQ"; exit 1; }
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
R=$(basename "$REQ" .md)
PROMPT="Role: Reviewer. Read $REQ and review per the reviewer flow. Do not edit source files."
REVIEWER=$(orca terminal create --worktree "path:$WT" --title "review $R · $(basename "$WT")" \
  --command "claude ${(q)PROMPT}" --json | h)
print -r -- "Reviewer opened for $REQ (reviewer=$REVIEWER)"

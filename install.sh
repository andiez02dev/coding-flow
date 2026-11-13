#!/bin/zsh
# Install Coding Flow for Orca, Claude and Codex.
#   ./install.sh           link every target to this repo (edit the repo, changes apply at once)
#   ./install.sh --copy    copy files instead (repo can be moved or deleted afterwards)
#   ./install.sh --status  show where each target points, change nothing
# Existing non-link targets are moved to ~/.coding-flow-backups/<timestamp>/ (outside skill
# folders, so agents never load backups as duplicate skills).
set -euo pipefail
here=${0:A:h}; mode=${1:-link}; bk="$HOME/.coding-flow-backups/$(date +%Y%m%d%H%M%S)"

pairs=(
  "$here/flow"              "$HOME/.orca/flow"
  "$here/agents/AGENTS.md"  "$HOME/.agents/AGENTS.md"
  "$here/agents/flow"       "$HOME/.agents/flow"
  "$here/bin/flow"          "$HOME/.local/bin/flow"
)
for s in "$here"/skills/*(/); do
  pairs+=("$s" "$HOME/.agents/skills/${s:t}" "$s" "$HOME/.claude/skills/${s:t}")
done
pairs+=("$HOME/.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$HOME/.agents/AGENTS.md" "$HOME/.codex/AGENTS.md")

if [[ $mode == --status ]]; then
  bad=0
  for src dst in "${pairs[@]}"; do
    if [[ -L $dst && ${dst:A} == ${src:A} ]]; then st="linked"
    elif [[ -e $dst ]] && diff -rq "$src" "$dst" >/dev/null 2>&1; then st="copy (same)"
    elif [[ -e $dst ]]; then st="DIFFERENT"; bad=1
    else st="MISSING"; bad=1; fi
    printf '%-12s %s\n' "$st" "${dst/#$HOME/~}"
  done
  exit $bad
fi

backup() {
  [[ -e $1 || -L $1 ]] || return 0
  if [[ -L $1 ]]; then rm -f "$1"; return; fi
  local d="$bk/${1#$HOME/}"; mkdir -p "${d:h}"; mv "$1" "$d"
}
for src dst in "${pairs[@]}"; do
  mkdir -p "${dst:h}"; backup "$dst"
  if [[ $mode == --copy && $src == $here/* ]]; then cp -R "$src" "$dst"; else ln -s "$src" "$dst"; fi
done
echo "Installed ($mode). Backups (if any): $bk. Choose Codex/Claude accounts in Orca."
[[ :$PATH: == *:$HOME/.local/bin:* ]] || echo "Add ~/.local/bin to PATH to use the 'flow' command."

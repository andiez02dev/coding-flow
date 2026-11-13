#!/bin/zsh
# Install Coding Flow: ~/.orca/flow, ~/.agents/{AGENTS.md,flow}, skills for Claude + Codex.
# Replaced files are backed up to ~/.coding-flow-backups/<timestamp>/ (outside skill folders,
# so agents never load backups as duplicate skills). AGENTS.md is linked for Claude/Codex.
set -euo pipefail
here=${0:A:h}; bk="$HOME/.coding-flow-backups/$(date +%Y%m%d%H%M%S)"
put() {
  mkdir -p "${2:h}"
  if [[ -e "$2" && ! -L "$2" ]]; then local d="$bk/${2#$HOME/}"; mkdir -p "${d:h}"; mv "$2" "$d"; else rm -rf "$2"; fi
  cp -R "$1" "$2"
}
put "$here/flow" "$HOME/.orca/flow"
put "$here/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
put "$here/agents/flow" "$HOME/.agents/flow"
for s in "$here"/skills/*(/); do put "$s" "$HOME/.agents/skills/${s:t}"; put "$s" "$HOME/.claude/skills/${s:t}"; done
for l in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"; do
  mkdir -p "${l:h}"
  if [[ -e "$l" && ! -L "$l" ]]; then local d="$bk/${l#$HOME/}"; mkdir -p "${d:h}"; mv "$l" "$d"; fi
  ln -sfn "$HOME/.agents/AGENTS.md" "$l"
done
echo "Installed. Backups (if any): $bk. Choose Codex/Claude accounts in Orca."

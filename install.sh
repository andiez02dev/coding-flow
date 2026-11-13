#!/bin/zsh
# Install Coding Flow: ~/.orca/flow, ~/.agents/{AGENTS.md,flow}, skills for Claude + Codex.
# Existing files are backed up to *.bak-<timestamp>. AGENTS.md is linked for Claude/Codex.
set -euo pipefail
here=${0:A:h}; ts=$(date +%Y%m%d%H%M%S)
put() { mkdir -p "${2:h}"; [[ -e "$2" && ! -L "$2" ]] && cp -R "$2" "$2.bak-$ts"; rm -rf "$2"; cp -R "$1" "$2"; }
put "$here/flow" "$HOME/.orca/flow"
put "$here/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
put "$here/agents/flow" "$HOME/.agents/flow"
for s in "$here"/skills/*(/); do put "$s" "$HOME/.agents/skills/${s:t}"; put "$s" "$HOME/.claude/skills/${s:t}"; done
for l in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"; do
  mkdir -p "${l:h}"; [[ -e "$l" && ! -L "$l" ]] && mv "$l" "$l.bak-$ts"; ln -sfn "$HOME/.agents/AGENTS.md" "$l"; done
echo "Installed. Optional: export CODEX2_HOME=<second Codex account home> for builder-1."

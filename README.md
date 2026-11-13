# Coding Flow

Lead / Builder / Reviewer coding workflow for [Orca](https://github.com/stablyai/orca): Claude plans and coordinates, Codex builds, a fresh Claude session reviews. Hand-offs go through files in `.flow/` in each worktree.

- **Lead** (Claude, `layout.sh`): writes `.flow/plan.md`, starts the Builder automatically, **asks you before every Reviewer**, writes `.flow/pr.md` after PASS and asks before push/PR.
- **Builder** (Codex): builds, runs Verify, commits in tested batches.
- **Reviewer** (fresh Claude): reviews the diff, picks checks with `scoped-verify` (full suite only in the final round or for DB changes).

## Layout
| Path | Installs to |
|---|---|
| `flow/` | `~/.orca/flow/` (layouts, coordinator guide, review template, tracker) |
| `agents/AGENTS.md` | `~/.agents/AGENTS.md`, linked as `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` |
| `agents/flow/plan.template.md` | `~/.agents/flow/` |
| `skills/` | `~/.agents/skills/` and `~/.claude/skills/` |

## Install
```zsh
./install.sh                      # backs up anything it replaces
cd <worktree> && ~/.orca/flow/layout.sh
```
Uses other skills you install separately (e.g. `orchestration`, `tdd`, `diagnosing-bugs`). Codex/Claude accounts are chosen by you in Orca; the flow never picks accounts. Repo rules always win over this flow.

## Test
`python3 flow/verify_flow.py` (stubs the Orca boundary; does not run real AI sessions).

`skills/verification-before-completion` is from obra/superpowers (MIT).

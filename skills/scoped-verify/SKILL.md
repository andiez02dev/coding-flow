---
name: scoped-verify
description: Use when reviewing or re-verifying a commit range (review rounds, re-review after fixes) to pick only the checks the diff can affect instead of the full suite. Uses only tools already in the repo; never installs packages.
---

# Scoped Verify

Pick checks from the diff since the **previous reviewed SHA** (or base SHA on round 1). Never add dependencies to the project to do this.

## 1. Get the scope
```bash
git diff --name-only <prev_reviewed_sha> <head_sha>
```

## 2. Choose checks

If the plan has a `## Scoped checks` table, use it. Otherwise use this default (layout: `fe/` frontend + Python backend):

| Changed paths | Run |
|---|---|
| Only `fe/**` | in `fe/`: `npm run lint`, `npm run typecheck`, `npx vitest run --changed <prev_reviewed_sha>` |
| Backend `src/**` or `tests/**` | `pytest` on the matching test files (step 3), SQLite (default env) |
| Migrations, `models`, `db/`, SQL/query code, `conftest.py`, deps or config (`pyproject.toml`, lockfiles, `Makefile`, CI) | full suite incl. Postgres (repo's full Verify) |
| Docs / `.flow/` only | no tests; say so |
| **Final round before merge** | full Verify from the plan, once |

Mixed diffs: union of the rows. When unsure which row applies, go one level wider.

## 3. Map backend changes to tests (no plugins)
- Changed test file → run it.
- Changed `src/<pkg>/<path>/<mod>.py` → `tests/test_<mod>*.py` plus `grep -rl "<mod>" tests/`.
- No match found → run the whole `tests/` on SQLite (not Postgres).

## 4. Reuse evidence
If the Build log shows the plan's Verify ran on exactly `<head_sha>` with exit 0, read it and only re-run the riskiest scoped check. A different SHA = no evidence.

## 5. Report
List: scope (files), which row(s) chose the checks, each command + exit code + pass/fail counts, and anything skipped with the reason (e.g. "Postgres skipped: FE-only diff, runs in final round"). Never claim PASS for checks not run. Freshly run scoped checks count as the full verification evidence required by `verification-before-completion` for this scope; claims must stay limited to that scope. Repo rules and an explicit plan requirement override this skill.

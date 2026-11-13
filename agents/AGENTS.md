# Verification

- Never claim work is done, fixed, or passing until you have run the relevant check (tests, typecheck, build, or exercising the real feature) in this session and seen it succeed.
- Report the command you ran and its result. If a check fails or could not be run, say so plainly instead of claiming success.

# Skills

- Bug, crash, failing test, or slowdown: use the `diagnosing-bugs` skill before proposing a fix.
- New feature or behavior change with a test setup available: use the `tdd` skill.
- In Codex, when using the shared engineering skills imported from Claude/Cursor, read `~/.agents/docs/harness/codex.md` once per session if it exists (optional, not part of this repo) for tool and model mappings.

# Coding flow (lead / builder / reviewer)

One task = one worktree = one branch. Hand-offs go through files in `.flow/` at the worktree root (ignored by git), never through chat paste. The repo's own AGENTS.md wins on any conflict (branch lifetime, checks, push rules).

This section applies only when the prompt names a Coding Flow role (Lead, Builder, Reviewer) or the worktree has `.flow/plan.md`; otherwise ignore it. Inside the flow, if your role is unclear, ask.

## Lead (Claude): investigate and plan
- Read the ticket (Jira key in the branch or prompt), the repo AGENTS.md and the code. Do not edit source files.
- Write `.flow/plan.md` from `~/.agents/flow/plan.template.md`, set `Status: planned`.
- A plan names the files to change, the acceptance criteria and the exact verify commands. If an open question blocks it, write it under Questions and stop.
- Split work for two builders only when the parts touch different files and do not depend on each other.

## Builder (Codex): build
- Read `.flow/plan.md` first. No plan or `Status` not planned/changes: stop and ask.
- Set `Status: building`. Change only what the plan lists; anything else goes under Deviations with the reason.
- Run every command under Verify. Paste the command and the pass/fail line under Build log. In correction rounds you may pick checks with the `scoped-verify` skill; run the full Verify on the final HEAD before the final review. Red: fix it or report it, never mark built.
- After Verify is green and the completed batch is committed under the policy below, set `Status: built`. Do not push or merge unless the person says so.
- When `.flow/review.md` says CHANGES: fix each finding, rerun Verify, set `Status: built` again.

## Commit policy
- Commit complete logical changes after their required checks pass, not each edit or individual review comment. Batch related PR comments/findings into one tested commit per correction round; split independent fixes when useful for review or revert. Do not force one commit per ticket.
- For corrections to an existing task commit, amend or use fixup/autosquash only on your own task branch after verifying that every rewritten commit is unpublished and unshared. If unsure, make a new commit. Never rewrite `main`, shared branches, published commits or other people's work automatically; do not force-push.
- Finish any eligible local history cleanup before handing the final SHA to review. Record the resulting HEAD and check evidence in `.flow/plan.md`; a changed SHA invalidates a previous PASS for the old SHA. Run the required Verify on the final checkout before claiming built; ask again before creating another Reviewer.
- A separate bug, a post-merge fix, or a correction to published work gets a new logical commit. Repository rules take precedence, including small-commit policies, staged migrations and generated files that must accompany their source change.

## Reviewer (Claude, fresh session): review
- Read `.flow/plan.md`, then `git diff <base>...HEAD` (base = the branch it was cut from, usually `main`); on re-review focus on the diff since the previous reviewed SHA plus related impact. Do not edit source files.
- Pick checks with the `scoped-verify` skill (full suite incl. Postgres only in the final round or for DB/migration changes); reuse Builder's Verify log when it ran on the exact SHA.
- Check: acceptance met, repo rules kept, tests cover the change, no scope creep, Verify actually ran green.
- Write `.flow/review.md`: `Verdict: PASS` or `Verdict: CHANGES`, then findings as `file:line — problem — fix`. Set plan `Status: review-pass` or `changes`.

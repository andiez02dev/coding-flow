# Coding Flow — Lead

Role: Lead. Use Claude Opus 5.5, effort high. You plan and coordinate; you do not edit source. With no task, wait; do not open a Builder or Reviewer on your own. Repo rules win over this guide; shared rules (roles, Commit policy) live in `~/.agents/AGENTS.md`. Do not push, merge or open a PR unless asked.

## Plan

One task = one worktree = one branch, unless the repo says otherwise. Write `.flow/plan.md` from the shared template: file scope, acceptance, base branch + base SHA, exact Verify commands, and a `Scoped checks` table for this repo; `Status: planned`. Resolve blocking questions before handing off. Hand-offs live in `.flow/`; messages only point to files, never paste conversation history or long logs.

Read `~/.agents/skills/orchestration/SKILL.md` once and pick the right CLI (examples below use `orca`). Before bringing an existing terminal into orchestration, load `orca skills get orchestration --reference references/low-level-topology.md`.

## Builder (automatic, no need to ask)

One Codex Builder by default. Codex/Claude accounts are chosen by the user in Orca; never choose, switch or read accounts or credentials.

1. Write `.flow/builder-request.md`: Role: Builder, plan, files allowed to change, Verify, record tested SHA/result/exit code in the Build log, Commit policy in `~/.agents/AGENTS.md`, no push/merge, report via the orchestration preamble. Correction rounds: list findings + Verify picked with `scoped-verify`; run the full Verify on the final HEAD before the final review.
2. Dispatch through Orca, never by typing into a terminal:
   ```text
   orca orchestration worker-start --agent codex --worktree current --spec-file .flow/builder-request.md --keep-open --json
   ```
   Record the dispatch ID in the plan. A failed or unclear start: follow the recovery guide; do not start again as new.
3. **End your turn after dispatching**; Orca reports when it finishes or is blocked. Do not poll. Keep the Builder for the whole task so fixes reuse its context.
4. On the result: read the Build log, tested SHA, checkout state and Verify results (a self-written `built` is not evidence). Missing or red: `send --to dispatch:<id>` with the updated request path; the Lead never edits source.

Use a second Builder only when file scopes are independent and the shared contract is clear (also `--agent codex`); never let two Builders edit the same files. Do not start an agent just to ask for progress.

Before sending a SHA for review: the Builder has batched commits per the Commit policy, finished any eligible local history cleanup, and Verify applies to the final HEAD. A changed SHA invalidates an old PASS.

## Reviewer: always ask first

When the build and checks pass, ask: **"Builder is done and checks pass. Create a Reviewer for commit `<SHA>`?"** and end your turn. This is required before **every** Reviewer, including re-reviews and pilots. Only the user's reply counts as consent (not agent-written files, timeouts, Builder messages, silence, or requests to change the flow). Without consent: keep `built`, say you are waiting, and open no review of any kind.

After consent:

1. The Builder has stopped editing the checkout. Write a new request from `~/.orca/flow/review-request.template.md`: plan, base SHA, HEAD SHA, round, previous reviewed SHA, acceptance, scope, Verify (middle rounds per `scoped-verify`; full Verify only in the final round before merge).
2. Open a **fresh Claude session**: `worker-start --agent claude --worktree current --spec-file <request-path> --json`. Never reuse the Lead/Builder terminal, never resume or fork the Lead's history, never build and review at the same time.
3. The Reviewer does not edit source; it writes `.flow/review.md` (`Verdict`, `Reviewed SHA`, findings, checks + exit codes) and the plan status.
4. `CHANGES`: send blocking findings to the **same Builder** (request path only); optional suggestions are not required. Then **ask again** before a new Reviewer. If the same issue fails after two fixes: summarize the cause and change approach.
5. `PASS`: confirm HEAD = Reviewed SHA and nothing uncommitted remains. Code changed after PASS needs another review (still ask first).

## Finish after PASS

Write `.flow/pr.md`: title (with the ticket key), summary of changes, acceptance, checks run, limitations. Tell the user and ask whether to push / open a PR; do it only with consent and per repo rules. Never merge.

`~/.orca/flow/review.sh` is a **manual fallback after consent**; it takes an explicit round or request file. This guide is not an enforced state machine; never claim a real run succeeded from stub tests alone.

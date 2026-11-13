# Review request — <task> — round <n>

Role: Reviewer (Claude, fresh session). Start only after the Lead has the user's consent for this round. Do not edit source; you may write the report and status in .flow. If dispatched by Orca, follow its preamble and report through orchestration.

Plan: <plan-path>
Base SHA: <base-commit>
Head SHA: <commit-to-review>
Round: <n>
Previous review: <report or none>
Previous reviewed SHA: <commit or none>
Report: .flow/review.md

## Scope and acceptance
- <files/features, acceptance to check>
- <later rounds: findings to confirm, new diff, related impact>

## Verify
```sh
<exact commands and environment conditions>
```

Read the plan and repo rules; confirm base/head and that no checkout is changing; repo rules take precedence. Read the diff and related code, acceptance, scope and tests. Pick checks with the `scoped-verify` skill (diff since the previous reviewed SHA; full suite/Postgres only in the final round or for DB/migration changes) unless the plan/rules require otherwise. Record commands, exit codes and evidence; red or unrunnable checks must be stated, never reported as PASS. A `built` status is not evidence.

Report:
```text
Verdict: PASS or CHANGES
Reviewed SHA: <commit actually reviewed>
Blocking findings:
- file:line — problem — fix
Optional suggestions:
- <non-blocking>
Checks:
- <command> → <exit code, pass/fail, log>
Limitations:
- <what was not verified>
```

Functional, data, security, accessibility, acceptance/rules issues or missing evidence may block. Style preferences without concrete harm are optional. Set plan `Status: review-pass` on PASS or `Status: changes` on CHANGES; do not commit source, push or merge. Do not create another Reviewer.

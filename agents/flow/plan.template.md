# <TICKET> — <title>

Status: planned
Base branch: main
Base SHA: <commit the branch was cut from>
Dispatch: <builder dispatch id>
Round: 0
Last reviewed SHA: none

## Goal
<one or two sentences: what changes for the user>

## Context
<what the code does today, the files involved, the pitfalls/docs that apply>

## Changes
- [ ] `path/to/file` — <what changes>

## Acceptance
- [ ] <observable result>

## Verify
```
<exact full-check commands, e.g. make check>
```

## Scoped checks
| Changed paths | Run |
|---|---|
| <e.g. `web/**`> | <lint/typecheck/tests limited to the change> |
| <e.g. migrations, deps, config> | full Verify |

## Questions
<blocking open questions; empty = none>

## Deviations
<builder: anything done outside Changes, and why>

## Build log
<builder: SHA → command → exit code, pass/fail>

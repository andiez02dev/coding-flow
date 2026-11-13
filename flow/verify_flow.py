#!/usr/bin/env python3
"""Check the script → Orca boundary without opening UI or calling a model."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent
STUB = '''#!/usr/bin/env python3
import json, os, pathlib, sys
log = pathlib.Path(os.environ['FLOW_CALL_LOG'])
prior = log.read_text().splitlines() if log.exists() else []
with log.open('a') as f: f.write(json.dumps(sys.argv[1:]) + chr(10))
mode = os.environ.get('FLOW_MODE') if len(prior) + 1 == int(os.environ.get('FLOW_FAIL_AT', '1')) else ''
if mode == 'exit': sys.exit(7)
if mode == 'bad-json': print('not JSON')
elif mode == 'no-handle': print(json.dumps({'ok': True, 'result': {}}))
elif mode == 'refused': print(json.dumps({'ok': False, 'result': {'handle': 'term_false'}}))
else: print(json.dumps({'ok': True, 'result': {'handle': 'term_' + str(len(prior) + 1)}}))
'''

with tempfile.TemporaryDirectory(prefix='coding-flow-check-') as tmp:
    sandbox = Path(tmp).resolve()
    fake = sandbox / 'orca'
    fake.write_text(STUB)
    fake.chmod(0o755)
    home = sandbox / "home ' $quote `tick`"
    flow = home / '.orca/flow'
    flow.mkdir(parents=True)
    log = sandbox / 'calls.jsonl'
    command_log = sandbox / 'commands.jsonl'
    recorder = '''#!/usr/bin/env python3
import json, os, sys
with open(os.environ['FLOW_COMMAND_LOG'], 'a') as f: f.write(json.dumps(sys.argv[1:]) + chr(10))
'''
    for target in [sandbox / 'claude', flow / 'track.sh', flow / 'codex2', sandbox / 'codex']:
        target.write_text(recorder)
        target.chmod(0o755)
    env = dict(os.environ, HOME=str(home), PATH=str(sandbox) + os.pathsep + os.environ['PATH'],
               FLOW_CALL_LOG=str(log), FLOW_COMMAND_LOG=str(command_log))

    def run(script, args=(), cwd=None, mode='', fail_at=1):
        log.unlink(missing_ok=True)
        command_log.unlink(missing_ok=True)
        result = subprocess.run(['zsh', str(ROOT / script), *args], cwd=cwd or ROOT,
                                env=dict(env, FLOW_MODE=mode, FLOW_FAIL_AT=str(fail_at)),
                                capture_output=True, text=True)
        calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
        return result, calls

    def value(call, flag):
        return call[call.index(flag) + 1]

    def execute_commands(calls):
        for call in calls:
            assert '--focus' not in call, call
            if '--command' in call:
                subprocess.run(['zsh', '-c', value(call, '--command')], cwd=worktree,
                               env=env, check=True, capture_output=True, text=True)
        return [json.loads(line) for line in command_log.read_text().splitlines()]

    worktree = sandbox / "project ' $UNSET `touch INJECTED`"
    worktree.mkdir()
    for args, cwd, title in [([str(worktree)], None, 'Coding Flow · ' + worktree.name),
                              ([], worktree, 'Coding Flow · ' + worktree.name),
                              ([str(worktree), 'My custom title'], None, 'My custom title')]:
        result, calls = run('layout.sh', args, cwd)
        assert result.returncode == 0, result.stderr
        assert value(calls[0], '--title') == title
        assert value(calls[0], '--worktree') == 'path:' + str(worktree)
        assert sum(c[:2] == ['terminal', 'split'] for c in calls) == 1
        commands = execute_commands(calls)
        assert commands[0][:4] == ['--model', 'claude-opus-5-5', '--effort', 'high'], commands
        assert commands[0][4].startswith('Role: Lead.') and str(flow / 'coordinator.md') in commands[0][4]
        assert commands[1] == [str(worktree)], commands
        assert not (worktree / 'INJECTED').exists()
    print('PASS: default/custom/cwd layout, model, role and safe command arguments')

    result, calls = run('manual-layout.sh', [str(worktree)])
    assert result.returncode == 0, result.stderr
    assert value(calls[0], '--title') == 'Coding Flow · ' + worktree.name
    assert sum(c[:2] == ['terminal', 'split'] for c in calls) == 3
    commands = execute_commands(calls)
    assert commands == [[], [], [], [str(worktree)]], commands
    assert any('codex2' in value(c, '--command') for c in calls if '--command' in c)
    assert any(value(c, '--command') == 'codex' for c in calls if '--command' in c)
    print('PASS: manual fallback keeps four panes and both account commands')

    (worktree / '.flow/nested').mkdir(parents=True)
    numeric = worktree / '.flow/review-request-r1.md'
    numeric.write_text('Review this commit.')
    nested = worktree / ".flow/nested/request ' $UNSET `touch INJECTED`.md"
    nested.write_text('Review this commit.')
    for request, expected in [('1', numeric), (str(nested.relative_to(worktree)), nested), (str(nested), nested)]:
        result, calls = run('review.sh', [str(worktree), request])
        assert result.returncode == 0, result.stderr
        assert len(calls) == 1 and calls[0][:2] == ['terminal', 'create'], calls
        commands = execute_commands(calls)
        assert len(commands) == 1 and len(commands[0]) == 1, commands
        assert commands[0][0].startswith('Role: Reviewer.') and str(expected) in commands[0][0], commands
        assert not (worktree / 'INJECTED').exists()
    print('PASS: explicit numeric/nested/absolute review request, fresh Claude, safe quoting')

    for args in [[str(worktree)], [str(worktree), '99'], [str(worktree), '.flow/no.md']]:
        result, calls = run('review.sh', args)
        assert result.returncode != 0 and not calls, (args, result, calls)
    print('PASS: reviewer refuses missing arguments or request before launching')

    for script, args, stages in [('layout.sh', [str(worktree)], [1, 2, 3]),
                                  ('manual-layout.sh', [str(worktree)], [1, 2, 3, 4, 5]),
                                  ('review.sh', [str(worktree), '1'], [1])]:
        for stage in stages:
            modes = ['exit', 'bad-json', 'no-handle', 'refused'] if stage < (3 if script == 'layout.sh' else 5) else ['exit']
            for mode in modes:
                result, calls = run(script, args, mode=mode, fail_at=stage)
                assert result.returncode != 0, (script, stage, mode, result)
                assert len(calls) == stage, (script, stage, mode, calls)
                assert not result.stdout.strip(), (script, stage, mode, result.stdout)
    print('PASS: Orca refusal/nonzero/malformed/missing handle stops without success or further commands')

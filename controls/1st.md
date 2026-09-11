# Controls

The checks this repository runs on itself, one file each, run the same way from a desk, from the pre-commit hook
and from the runner, and printing the same lines wherever they run. Their shape is the subject of
[rfc-013](https://github.com/empowerite/jig/issues/58).

## Running

- `controls/run <event>` runs every control of an event: `pre-commit` over the staged files, `pull-request` over
  the pull request's files, `schedule` over the tree. When the change deletes a file, every changed-scope control
  runs over the tree instead.
- `controls/<name> --all`, or `controls/<name> --changed <file>...`, runs one control by hand and prints what the
  runner would print. `controls/must-close-open-issue --pull-request <N>` reads a pull request from a desk.
- `git config core.hooksPath controls/hooks` makes every commit run the pre-commit event; the tools come from
  `mise`, so the shell that commits has `mise` activated.
- `controls/common.bash` is what every control sources: the argument shape, `refuse`, `pass`, the summary sink.

## Manifest

| control | events | scope | needs |
| --- | --- | --- | --- |
| actionlint | pre-commit, pull-request, schedule | all | |
| unique-rfc-numbers | pre-commit, pull-request, schedule | all | |
| links-resolve | pre-commit, pull-request, schedule | changed | |
| must-close-open-issue | pull-request | | |

Events name when a control runs. Scope is what it is given: `all`, the tree; `changed`, the files that changed,
which becomes `all` on the schedule and when the change deletes a file; empty, a control that reads the pull
request and not files. `needs` names what a control consumes, in make's direction, and a control runs only after
what it needs has passed.

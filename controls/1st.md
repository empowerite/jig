# Controls

The checks this repository runs on itself, one file each. A control judges a subject at a moment, and it runs
the same way from a desk, from the pre-commit hook and from the runner, printing the same lines wherever it runs.
Its shape is the subject of [rfc-013](https://github.com/empowerite/jig/issues/58).

## Running

- `controls/run <moment>` runs every control of a moment: `drafting` over the staged change, which the pre-commit
  hook invokes; `admission` over the pull request's change, which the runner invokes on a pull request; `sweep`
  over the tree, which the runner invokes on a schedule. A change that deletes a file is judged over the tree.
- `controls/<name> --all`, or `controls/<name> --changed <file>...`, runs one control by hand and prints what the
  runner would print. `controls/must-close-open-issue --pull-request <N>` reads a pull request from a desk.
- `git config core.hooksPath controls/hooks` makes every commit invoke the drafting moment; the tools come from
  `mise`, so the shell that commits has `mise` activated.
- `controls/common.bash` is what every control sources: the argument shape, `refuse`, `pass`, the summary sink.

## Manifest

| control | moments | subject | needs |
| --- | --- | --- | --- |
| actionlint | drafting, admission, sweep | change, all | |
| unique-rfc-numbers | drafting, admission, sweep | change, all | |
| links-resolve | drafting, admission, sweep | change, changed | |
| must-close-open-issue | admission | pull request | |

Moments name when a control runs. The subject is what it is given: a change at breadth `all`, the tree, or
`changed`, the files that changed, which becomes `all` on the sweep and when the change deletes a file; or the
pull request, for a control that reads it and not files. `needs` names what a control consumes, in make's
direction, and a control runs only after what it needs has passed.

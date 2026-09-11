# Controls: one file, run from a desk, a hook or a runner, in changed or all scope

Status: draft

## Decision

A control is one executable file. It is run the same way from a desk, from a pre-commit hook and from a runner,
and it prints the same annotations and the same remedy wherever it runs. A workflow holds no control; it runs
them.

### The file

A control takes `--changed`, followed by the files that changed, or `--all`, and judges what it was given. A
control whose subject is not a set of files, the one that reads a pull request, takes neither. Its data lives
where its tool looks for it: `actionlint` reads `.github/actionlint.yml` because that is where `actionlint` looks,
and the control does not move it.

### The manifest

Beside the controls, `controls/1st.md` is their index and carries the manifest: one row per control naming its
events, its scope at each event, and what it needs.

- An event is pre-commit, pull-request or schedule, and a control belongs to any of them.
- Scope at an event is `changed` or `all`. A pull request whose diff deletes a file runs every `changed` control
  at `all`, and the schedule runs at `all`; that is what makes the changed-files optimization safe, since a link
  in an unchanged file can break when its target is deleted.
- `needs` names what a control consumes, in make's direction: the row names its prerequisites, never what
  follows it. A control that generates the index is needed by the one that checks links.

The runner, `controls/run <event>`, reads the manifest, computes the changed set once, from the staged files on a
desk and the pull request's diff on a runner, and runs every control of the event. Independent controls run in
any order, and all of them report; a control whose need failed is skipped and says so. Nothing stops at the first
red. The toolchain, `mise install`, precedes everything and is declared by no row.

### Where it lives

`controls/` sits at the root of a repository, beside `docs/`, with `1st.md` first in it. It does not sit under
`.github/`, because a control is not GitHub's, and it is not a dot-directory, because a hidden tree a tool drops
into a repository is the copy problem under another name. `controls/hooks/pre-commit` runs `controls/run
pre-commit` and is what `core.hooksPath` points at.

A `controls/` directory governs the subtree rooted at its parent, the rule that [rfc-007-jig-discover.md](rfc-007-jig-
discover.md) gives rule files. The root's binds everything; `projects/foo/controls/` binds `projects/foo/**`. Each
control sees its own subtree's slice of the change, a control's name is qualified by its path, controls add and never
remove, and a `needs` may name an ancestor's control and never a sibling subtree's. One runner at the root discovers
every `controls/` in the tree.

### Where it goes

The manifests become the gates tables in `jig.toml`, one per subtree, as
[rfc-003-policy.md](rfc-003-policy.md) has them. A control shared beyond one repository becomes an extension,
`jig-<name>`, released and pinned on its own. A project's own control stays a program `jig.toml` names by path.
`controls/run` is the first thing the engine of [rfc-012-distribution.md](rfc-012-distribution.md) replaces, and
no control file is ever compiled into jig.

## Why

- One file per control, because a step inlined in a workflow cannot be run on a desk, cannot be moved to a hook
  without copying its script, and cannot be debugged without a push.
- Scope declared per event, because a check over changed files is fast and a check over the tree is safe, and
  only the manifest knows which a moment needs; a delete is the case that proves it.
- `needs` in make's direction, because a control that named its successor would be deciding when another runs,
  and that edge points the wrong way.
- All run and all report, because a pull request that shows one refusal per push costs a push per refusal.
- The tree as the table, because a routing kept apart from what it routes is a second thing to keep in step, and
  a subtree's controls belong with the subtree.
- Nothing compiled into jig, because jig is a policy engine and not a policy.

## Consequences

- The four policies this repository runs become four control files, a manifest, a runner and a hook, and the
  workflow becomes one line per event; see [the refactor][refactor].
- `docs/install.md` gains the `core.hooksPath` line.
- `rfc-003` is amended so that a `jig.toml` per subtree adds to the root's; see [the amendment][amend].

## Open questions

- Whether the manifest is the table in `1st.md` or a file the runner reads without parsing Markdown, once
  `jig verify` reads it from `jig.toml` instead.
- Whether independent controls run concurrently on a runner, and how their output interleaves.

[refactor]: https://github.com/empowerite/jig/issues/59
[amend]: https://github.com/empowerite/jig/issues/60

# Controls: a control judges a subject at a moment, from a desk, a hook or a runner

Status: draft

## Decision

A control is one executable file that judges a subject at a moment. It runs the same way from a desk, from a
hook and from a runner, and it prints the same annotations and the same remedy wherever it runs. A workflow holds
no control; it invokes them.

### The subject

A control is given one subject, and its kind is declared in the manifest:

- A change: a set of files, at one of two breadths. `--changed` names the files that changed; `--all` names the
  whole tree. A change that deletes a file is judged at `--all`, because a link in an unchanged file breaks when
  its target goes, and the periodic sweep is judged at `--all` for the same reason.
- A pull request: the provider's object, with its links, reviews and verdicts, read through a port.
- A tree: a commit's whole content, which is what a batch's speculative tree is.
- A release: the artifacts a tag carries.
- The board: the view of [rfc-001-world-model.md](rfc-001-world-model.md) itself, for a control that judges
  the lifecycle rather than a file, such as one that refuses two open pull requests closing the same issue.

The subjects this repository judges today are a change and a pull request; the others are named so that a control
wanting one has a word for it.

### The moment

A moment is a transition of the lifecycle, or the periodic sweep. It is named in the model's own words and never
in a host's: drafting, when a commit is made; admission, when a proposed change is judged for admissible;
integrating, when a batch's tree is tested; realizing, when the post-integration verdict is read; releasing, when
a tag is cut; and the sweep, on a schedule, over everything. How a moment is invoked on a host is the host's
business and the port's: on a desk, drafting is the pre-commit hook; on a runner, admission is the pull request
event and the sweep is the schedule. A manifest names moments and knows nothing of events.

This repository invokes three moments today, drafting, admission and the sweep.

### The manifest

Beside the controls, `controls/1st.md` is their index and carries the manifest: one row per control naming its
moments, its subject, the breadth of a change at each moment, and what it needs.

`needs` names what a control consumes, in make's direction: the row names its prerequisites, never what follows
it. A control that generates the index is needed by the one that checks links. Independent controls run in any
order and all of them report; a control whose need refused is skipped and says so. Nothing stops at the first
refusal. The toolchain, `mise install`, precedes everything and is declared by no row.

### The runner

`controls/run <moment>` reads the manifest, computes the subject once, the staged change on a desk and the pull
request's change on a runner, runs every control of the moment, and exits non-zero if any refused, after all have
reported. It is the one place a moment meets a host.

### The module system

A control's entry is one file, and its body is a function in a sourced bash module system this repository will
carry: a loader, namespaced functions, `control:links-resolve`, and shared modules for what every control
shares, the argument shape, the refusal, the pass, the summary sink. The controls are written against that
system now, with the shared module as a single sourced file until the loader arrives, so that the loader's arrival
is a move and not a rewrite. The loader and its namespaces are their own RFC.

### Where it lives

`controls/` sits at the root of a repository, beside `docs/`, with `1st.md` first in it. Not under `.github/`,
because a control is not GitHub's; not a dot-directory, because a hidden tree a tool drops into a repository is the
copy problem under another name. `controls/hooks/pre-commit` invokes the drafting moment and is what
`core.hooksPath` points at. A control's data lives where its tool looks for it: `actionlint` reads
`.github/actionlint.yml` because that is where `actionlint` looks.

A `controls/` directory governs the subtree rooted at its parent, the rule that
[rfc-007-jig-discover.md](rfc-007-jig-discover.md) gives rule files. The root's binds everything;
`projects/foo/controls/` binds `projects/foo/**`. Each control sees its subtree's slice of the change, a control's
name is qualified by its path, controls add and never remove, and a `needs` may name an ancestor's control and
never a sibling subtree's. One runner at the root discovers every `controls/` in the tree.

### Where it goes

The manifests become the gates tables in `jig.toml`, one per subtree, as [rfc-003-policy.md](rfc-003-policy.md)
has them, and a gate on a transition is a control at that moment. A control shared beyond one repository becomes an
extension, `jig-<name>`, released and pinned on its own. A project's own control stays a program `jig.toml` names
by path. `controls/run` is the first thing the engine of [rfc-012-distribution.md](rfc-012-distribution.md)
replaces, and no control file is ever compiled into jig.

## Why

- A subject and a moment, because a control that knew only "files" and "pull request event" could judge neither a
  batch's tree nor a release, and would have to be rewritten when the lifecycle asked for either.
- Moments in the model's words, because a manifest that said `pull_request` would be a GitHub manifest, and the
  same control on another host, or on a desk, has no such event to name.
- One file per control, because a step inlined in a workflow cannot be run on a desk, cannot be moved between
  moments without copying its script, and cannot be debugged without a push.
- Breadth declared per moment, because a check over changed files is fast and a check over the tree is safe, and
  a delete is the case that shows only the manifest knows which a moment needs.
- `needs` in make's direction, because a control that named its successor would be deciding when another runs.
- All run and all report, because a pull request that shows one refusal per push costs a push per refusal.
- Written against the module system before it exists, because a body that is already a function moves into a
  module by being moved, and a body that is a script has to be rewritten to become one.
- Nothing compiled into jig, because jig is a policy engine and not a policy.

## Consequences

- The four policies this repository runs become four control files, a manifest, a runner and a hook, and the
  workflow becomes one line per moment; see [the refactor][refactor].
- `docs/install.md` gains the `core.hooksPath` line.
- `rfc-003` is amended so that a `jig.toml` per subtree adds to the root's; see [the amendment][amend].
- The module system gets its RFC, and the shared module is its first member; see [the modules RFC][modules].

## Open questions

- Whether the manifest stays a table in `1st.md` or becomes a file the runner reads without parsing Markdown, once
  `jig verify` reads it from `jig.toml` instead.
- Whether independent controls run concurrently on a runner, and how their output interleaves.
- Which moments a desk can invoke beyond drafting: a pre-push hook is a natural second.

[refactor]: https://github.com/empowerite/jig/issues/59
[amend]: https://github.com/empowerite/jig/issues/60
[modules]: https://github.com/empowerite/jig/issues/64

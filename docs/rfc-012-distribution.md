# Distribution: how gates, workflows and rulesets reach every repository

Status: draft

## Decision

jig is a policy engine and not a policy. It ships no gate. What reaches a repository is the engine, one workflow
that runs it, and the gates the repository's policies name, and none of the three is a file copied into that
repository.

### The engine

`jig verify` reads every policy that applies to a repository, runs the gates those policies name, and reports each
one as an annotation, a log line and a summary. It carries no gate of its own. A gate is an extension or a script,
and the engine knows how to run both and nothing about what either checks.

### Two classes of gate

A gate belongs to the organization or to the repository. The classes differ in who owns the policy that names the
gate and in what may run it; the engine treats them alike.

- An organization gate is named in a policy the organization owns, kept in the central repository its workflow is
  served from and read beside the repository's own file. A repository cannot weaken or remove it by editing
  `jig.toml`. It is an extension the organization pins by version from a release it controls, so that it cannot be
  tampered with, and a fix to it is a release of the extension and never of jig.
- A repository gate is the project's own, named in its `jig.toml`. It is whatever the repository names: a script or
  a command in the tree first of all, `just test` or `controls/coverage`; an extension when it is shared with other
  teams. Nothing about it is copied anywhere, and debugging it never means releasing jig. Whether it is required
  is the repository's own branch ruleset to say.

The organization adds, the repository adds, nobody removes. The engine runs the union, and a refusal names the
policy its gate came from.

### What a repository holds

`jig.toml`, and the scripts its own gates name, wherever it keeps them. Nothing under `.github/`. The bash in
this repository's own workflow is a stand-in until its controls arrive; see [rfc-013][rfc013].

### The workflow

This repository ships one workflow with `workflow_call`. It checks out, installs the pinned jig, and runs
`jig verify` over both policies. An organization requires it through an organization-level ruleset that names the
workflow, which runs it in every repository with no file in any of them, beside the branch ruleset that requires
the check. A repository outside that requirement, or one that wants its own gates alone, writes a five-line
caller, `uses: empowerite/jig/.github/workflows/verify.yml@v1`, against its own file. Both rulesets are
Terraform. Maintenance is one file, and rollout is a tag.

### Releases

A GitHub Release carries the `jig` binary for each platform with the interface embedded, the schema file, and
checksums. `mise` installs it from the release with no registry entry, `"ubi:empowerite/jig" = "<version>"`; a
desk pins it in `mise.toml`, and the workflow installs the same pin through `mise-action`, so both run the same
bytes. An extension, `jig-<name>`, is a release of its own, installed and pinned the same way; see
[rfc-006-extensions.md](rfc-006-extensions.md).

### What this repository keeps

`actionlint.yml`, the runner labels, and the workflow that lints and tests its own workflows. A consumer never
sees them, because a consumer has no workflow of its own to lint.

## Why

- No gate in jig, because an engine that carried a policy would make one organization's rule every
  organization's binary, and a rule that needed an engine release to change would change at the engine's pace.
- Two classes and one engine, because only the organization's gates have the copy problem, and a design that
  solved it by taking a repository's own gates out of its hands would trade one wrong for another.
- The organization's gates as pinned extensions, because a gate in YAML is a gate copied, and a copy in thousands
  of repositories is thousands of versions. A pinned extension is one, and a fix is a release of it.
- The repository's gates as its own scripts, because a project's controls change with the project, and a change
  that needed a jig release to debug would make jig the bottleneck of every team at once.
- A ruleset over a caller file, because a file that must exist in every repository is a file that will be missing
  from some, and a workflow the ruleset injects has nothing in the repository's tree to drift.
- Releases through `mise`, because the desk and the runner must run the same bytes, and one pin read by both is
  the only way to say so.

## Consequences

- [rfc-003-policy.md](rfc-003-policy.md) names a gate as an extension or a command by path, and says which class
  may use which. No gate is a verb of the engine.
- [rfc-010-release.md](rfc-010-release.md)'s release section changes: with `ubi` as the install path, `mise`
  installs whatever the release says, and artifact signing becomes the first open question to close.
- The infrastructure that manages the branch ruleset manages the organization ruleset beside it.
- The controls in this repository are repository gates today and the organization's first extensions when they are
  shared; see [rfc-013][rfc013].

## Open questions

- Where the organization's policy lives and what it may say. The central repository the workflow is served from is
  the natural home; whether it may also pin the jig version every repository runs is undecided.
- How GitHub composes a check's name for a reusable workflow and for a required one, since
  `required_status_checks` must name it exactly. Measured on a scratch repository before the ruleset is written.
- Whether `jig verify` also runs on a desk before a commit, as the pre-commit hook, so a refusal is met before a
  push.
- Whether the reusable workflow and the action live in this repository or in one of their own.

[rfc013]: https://github.com/empowerite/jig/issues/58

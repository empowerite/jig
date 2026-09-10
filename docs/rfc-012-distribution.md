# Distribution: how gates, workflows and rulesets reach every repository

Status: draft

## Decision

jig reaches a repository in three layers, and none of them is a file copied into that repository.

### Two classes of gate, one mechanism

jig is a policy engine and not a policy: it ships no gate. `jig verify` reads the policies that apply, runs
what they name, and reports; every gate is an extension or a script. A gate is one of two classes, and the classes
differ in who owns the policy that names it and in what may run it.

- An organization gate is named in a policy the organization owns, kept in the central repository the required
  workflow is served from, versioned there, and read by `jig verify` beside the repository's own file. A
  repository cannot weaken or remove one by editing `jig.toml`. What runs it is an extension the organization
  pins, by version, from a release it controls, so that it cannot be tampered with and a fix is a release of the
  extension and never of jig. This is the class with the copy problem, and the organization ruleset below is what
  solves it.
- A repository gate is the project's own, named in its `jig.toml`. What runs it is whatever the repository names:
  a script or a command in the repository first of all, `just test` or `controls/coverage`; an extension when it
  is shared with other teams. Nothing about it is copied anywhere, the engine that runs it is the only shared
  thing, and debugging it never means releasing jig. Whether it is required is the repository's own branch
  ruleset, a per-repository choice.

The precedence rule is one line: the organization adds, the repository adds, nobody removes. `jig verify` runs
the union, and a refusal names which policy the gate came from.

### What a consumer repository holds

`jig.toml`, and the scripts its own gates name, wherever it keeps them. Nothing under `.github/`. The bash that
runs this repository's gates in its workflow today is a stand-in, and each step goes when its control arrives.

### One reusable workflow, required by the organization

This repository ships one workflow with `workflow_call`: check out, install the pinned jig, run `jig verify` over
both policies. An organization requires it through an organization-level ruleset that names the workflow, which
runs it in every repository with no file in any of them, beside the branch ruleset that requires the check; so a
repository needs no workflow file for either class of gate. A repository outside such an organization, or one
that wants its own gates without the organization's requirement, writes a five-line caller,
`uses: empowerite/jig/.github/workflows/verify.yml@v1`, against its own file alone. Both rulesets are Terraform.
Maintenance is one file, and rollout is a tag.

### Releases install through mise

A GitHub Release carries the `jig` binary per platform with the interface embedded, the schema file, and checksums.
`mise` installs it from the release with no registry entry, `"ubi:empowerite/jig" = "<version>"`, so a desk pins it in
`mise.toml` and the reusable workflow installs the same pin through `mise-action`. An extension, `jig-<name>`, is a
release of its own installed and pinned the same way, as [rfc-006-extensions.md](rfc-006-extensions.md) requires.

### What this repository keeps

`actionlint.yml`, the runner labels, and the workflow that lints and tests this repository's own workflows. A
consumer never sees them, because a consumer has no workflow of its own to lint.

## Why

- Two classes with one mechanism, because only the organization's gates have the copy problem, and a design
  that solved it by taking a repository's own gates out of its hands would trade one wrong for another.
- No gate in jig, because an engine that carried a policy would make one organization's rule every
  organization's binary, and a rule that needed an engine release to change would change at the engine's pace.
- The organization's gates as pinned extensions, because a gate in YAML is a gate copied, and a copy in thousands
  of repositories is thousands of versions; a pinned extension is one, and a fix is a release of it.
- The repository's gates as its own scripts, because a project's control changes with the project, and a change
  that needed a jig release to debug would make jig the bottleneck of every team at once.
- A reusable workflow and an organization ruleset, because a file that must exist in every repository is a file
  that will be missing from some, and a ruleset that injects the workflow makes the repository's own tree the
  wrong place to look for it, which is where it should not be.
- Releases through `mise`, because the desk and the runner must run the same bytes, and one pin read by both is
  the only way to say so.

## Consequences

- [rfc-010-release.md](rfc-010-release.md)'s release section changes: `ubi` as the install path makes artifact
  signing the first open question to close, since `mise` will install whatever the release says.
- [rfc-003-policy.md](rfc-003-policy.md) names a gate as an extension or a command by path, and says which
  class may use which; no gate is a verb.
- The infrastructure that manages the branch ruleset manages the organization ruleset beside it.
- The controls in this repository, [rfc-013][rfc013], are repository gates today and the organization's first
  extensions when they are shared.

## Open questions

- Where the organization's policy file lives and what it may say: the central repository the workflow is
  served from is the natural home, and whether it may also pin the jig version every repository runs.
- How GitHub composes the check's display name for a reusable and for a required workflow, since
  `required_status_checks` must name it exactly; measured on a scratch repository before the ruleset is written.
- Whether `jig verify` also runs on a desk before a commit, as the pre-commit hook, so a refusal is met before a
  push.
- Whether the reusable workflow and the action live in this repository or in one of their own.

[rfc013]: https://github.com/empowerite/jig/issues/58

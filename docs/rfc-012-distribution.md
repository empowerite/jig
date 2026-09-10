# Distribution: how gates, workflows and rulesets reach every repository

Status: draft

## Decision

jig reaches a repository in three layers, and none of them is a file copied into that repository.

### Gates live in the binary

Every policy a repository's pull requests must satisfy is a `jig verify` verb: `jig verify pull-request` reads
`jig.toml` and the pull request and passes or refuses, with the annotation, the log line and the summary a person
already knows. A gate is therefore one implementation, in Go, versioned with jig, tested against the fakes of
[rfc-002-ports.md](rfc-002-ports.md), and named in the policy of [rfc-003-policy.md](rfc-003-policy.md) rather
than in any workflow. The bash that runs the gates in this repository today is a stand-in, and each step goes when
its verb arrives. What a consumer repository holds is `jig.toml`, and nothing under `.github/`.

### One reusable workflow, required by the organization

This repository ships one workflow with `workflow_call`: check out, install the pinned jig, run `jig verify`. A
repository that wants it writes a five-line caller, `uses: empowerite/jig/.github/workflows/verify.yml@v1`. An
organization that wants it everywhere requires it through an organization-level ruleset that names the workflow,
which runs it in every repository with no file in any of them, beside the branch ruleset that requires the
check. Both rulesets are Terraform. Maintenance is one file, and rollout is a tag.

### Releases install through mise

A GitHub Release carries the `jig` binary per platform with the interface embedded, the schema file, and checksums.
`mise` installs it from the release with no registry entry, `"ubi:empowerite/jig" = "<version>"`, so a desk pins it in
`mise.toml` and the reusable workflow installs the same pin through `mise-action`. An extension, `jig-<name>`, is a
release of its own installed and pinned the same way, as [rfc-006-extensions.md](rfc-006-extensions.md) requires.

### What this repository keeps

`actionlint.yml`, the runner labels, and the workflow that lints and tests this repository's own workflows. A
consumer never sees them, because a consumer has no workflow of its own to lint.

## Why

- Gates in the binary, because a gate in YAML is a gate copied, and a copy in thousands of repositories is
  thousands of versions; a verb is one, and a fix is a release.
- A reusable workflow and an organization ruleset, because a file that must exist in every repository is a file
  that will be missing from some, and a ruleset that injects the workflow makes the repository's own tree the
  wrong place to look for it, which is where it should not be.
- Releases through `mise`, because the desk and the runner must run the same bytes, and one pin read by both is
  the only way to say so.

## Consequences

- [rfc-010-release.md](rfc-010-release.md)'s release section changes: `ubi` as the install path makes artifact
  signing the first open question to close, since `mise` will install whatever the release says.
- [rfc-003-policy.md](rfc-003-policy.md) gains the gates' names as `jig verify` knows them, so a policy names a
  verb and not a script.
- The infrastructure that manages the branch ruleset manages the organization ruleset beside it.
- The two policies in this repository's workflow are the first two verbs.

## Open questions

- How GitHub composes the check's display name for a reusable and for a required workflow, since
  `required_status_checks` must name it exactly; measured on a scratch repository before the ruleset is written.
- Whether `jig verify` also runs on a desk before a commit, as the pre-commit hook, so a refusal is met before a
  push.
- Whether the reusable workflow and the action live in this repository or in one of their own.

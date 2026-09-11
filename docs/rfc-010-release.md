# Release: jig's own lifecycle, releases

Status: draft

## Decision

This repository runs on jig. Its `jig.toml` declares its own policy, its pull requests pass its own policy checks,
and its board is its own issues. Until the binary exists, `CLAUDE.md` and the workflow stand in, and each
paragraph of the former goes when jig takes its job.

### A release

A release is a git tag, `vMAJOR.MINOR.PATCH`, and what it carries:

- The `jig` binary for each platform, the interface embedded, built by this repository's workflow from the tag
  with the toolchain `mise.toml` pins, so the build is reproducible from the tag alone.
- The action a consumer's workflow uses, which installs that binary and nothing else.
- The GraphQL schema file, which is the public contract at that version.

### The version

The lifecycle of [rfc-001-types.md](rfc-001-types.md) is versioned with the code, and the version number
says what changed. A change to the states or their transitions is a major release; a new gate kind, verb, port
capability or extension point is a minor one; a fix that changes no contract is a patch. A lifecycle change lands only
after its spec is accepted, so a major release is announced by a spec before it is cut.

### A consumer

A consumer pins `jig` in its own `mise.toml` and the action in its workflow, and updates both together.
`jig doctor` reports the version it is, the lifecycle version the repository's policy targets, and whether they
agree. `jig policy plan` is run before an update that changes the lifecycle, since such an update is a policy
change.

## Why

- Dogfood, because a harness that does not run on itself has no user who feels its friction first.
- The lifecycle in the version number, because a consumer deciding whether to update needs one number that says
  whether its process changes.
- Reproducible from the tag, because a binary nobody can rebuild is a binary nobody can trust, and the pinned
  toolchain is what makes the rebuild the same.

## Consequences

- `mise.toml` in this repository pins Go, Node and the tools; a consumer pins only `jig`.
- The changelog is derived from landed subjects, `#<N> <file>: <subject>`, which is what the subject convention
  is for.
- A schema change is a release that can count what it breaks, since every extension names the schema version it
  was written against.

## Open questions

- How release artifacts are signed, and with what key, so that a consumer can verify what `mise` installed.
- Whether the action lives in this repository or in one of its own.

# Release: jig's own lifecycle, releases

Status: draft

## Decision

This repository runs on jig. Its own policy, in the language of [rfc-002-language.md](rfc-002-language.md), declares
its types and attaches its gates; its pull requests pass those gates; and its board is its own issues.

### A release

A release is a git tag, `vMAJOR.MINOR.PATCH`, and what it carries:

- The `jig` binary for each platform, the interface embedded, built by this repository's workflow from the tag
  with the toolchain `mise.toml` pins, so the build is reproducible from the tag alone.
- The reusable workflow other repositories invoke rather than copy, which checks out, installs the pinned binary by
  its checksum and runs `jig verify`.
- The GraphQL schema file, which is the public contract at that version.
- The standard policy of [rfc-002-language.md](rfc-002-language.md), the CUE module and the Rego bundle, at its own
  version, so that a consumer can pin it as a link of the chain.
- Checksums over every artifact. A consumer's `mise` installs the binary straight from the release by them.

Where a tag points: a major or a minor is a tag on `main`, at the commit that becomes `vX.Y.0`. A patch is a tag on
that minor's release branch, `release/X.Y`, cut from `main` at the same commit and carrying only fixes, each landed on
`main` first and cherry-picked. A pre-release is a tag on `main` before the `.0`, `vX.Y.0-rc.N`, since no branch
exists yet and an rc's fixes are ordinary commits. The branch is cut at the `.0`; if a minor ever needs `main` to move
on during a long stabilization, it is cut at the first rc instead and the rcs tag the branch, and nothing else
changes. In the model a release is a type: its location is the scm port's tags, its name rule is the version pattern,
its creating action tags a commit, and the guard on that action reads the branch.

### The version

The lifecycle is data and is versioned with the policy that declares it, never with the binary. The binary's version
says what changed in its contracts: a change to a kind of [rfc-001-types.md](rfc-001-types.md), to the port contract
of [rfc-003-ports.md](rfc-003-ports.md), or to the schema is a major release; a new port capability, verb, extension
point or standard rule is a minor one; a fix that changes no contract is a patch. The standard policy is versioned on
its own, the same way, and a change to the standard lifecycle is a major release of the standard policy and never of
the binary. A change to a kind lands only after its RFC is accepted, so a major release of the binary is announced by
an RFC before it is cut.

### A consumer

A consumer pins three things and may update each on its own: the binary in its `mise.toml`, the standard policy as a
link of its chain, and the reusable workflow it invokes. `jig doctor` reports the binary's version, the standard
policy's version the chain pins, and whether the binary serves that policy's schema. `jig policy plan` is run before
an update to the standard policy, since such an update is a policy change.

## Why

- Dogfood, because a harness that does not run on itself has no user who feels its friction first.
- The lifecycle in the policy's version and not the binary's, because a consumer deciding whether to update the binary
  needs to know whether its contracts change, and one deciding whether to update the standard policy needs to know
  whether its process changes, and those are two decisions with two numbers.
- Reproducible from the tag, because a binary nobody can rebuild is a binary nobody can trust, and the pinned
  toolchain is what makes the rebuild the same.

## Consequences

- `mise.toml` in this repository pins Go, Node and the tools; a consumer pins only `jig`.
- The changelog is derived from landed subjects, `#<N> <file>: <subject>`, which is what the subject convention
  is for.
- A schema change is a release that can count what it breaks, since every extension names the schema version it
  was written against.
- The standard policy's release is what an organization's link pins beneath its own, as the chain of
  [rfc-001-types.md](rfc-001-types.md) has it.
- A patch is a change whose target is not the default branch, and integrated as [rfc-001-types.md](rfc-001-types.md)
  has it means landed on the default branch; the change type gains its target as a declared parameter when rfc-001 is
  next amended.

## Open questions

- How release artifacts are signed and with what key, and whose key signs a verdict and how a consumer verifies both,
  so that what `mise` installed and what an attestation claims can each be checked.
- Whether the action, the reusable workflow and the standard policy live in this repository or in one of their own; a
  standard policy versioned on its own inside this repository needs a tag namespace of its own, `policy/vX.Y.Z`.

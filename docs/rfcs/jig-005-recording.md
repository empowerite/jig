# Recording: the evidence store, versions, and the snapshot of an issue

Status: draft

## Decision

Recording, in [jig-000-charter.md](jig-000-charter.md), writes every grounded state of
[jig-002-lifecycles.md](jig-002-lifecycles.md) as the record of the transition that entered it. This RFC says
where the record goes and what a version is for each of the standard types of
[jig-003-machines.md](jig-003-machines.md).

### The store

- The evidence store is pluggable. A repository declares which one its records go to, and jig ships one: a hidden
  ref in the repository's own git history, outside the branches, one commit per record over the previous.
- A record names the transition, the actor and the actor's origin, the value and its version, the verdicts the gate
  demanded with their producers, what was found missing, and the time. It is signed on the desk that wrote it.
- The record is the desk process's to read across versions, so its format is versioned on its own and every later
  version of jig reads every earlier format.

### Versions

- A pull request's version is its head commit, and a release's is the commit it tags; both are content-addressed
  already, and the record keeps the digest.
- An issue has no version of its own, so each `submit(proposal)` snapshots its title, body and labels into the
  store, and that snapshot's digest is the version the verdicts key on. An edit between two submits is a fact, not a
  version, and the body's own edit history on the provider is where the intermediate content is found.
- A deployment's version is the release it deploys and the target it deploys into.

### Facts about mutable entities

A fact recorded about something that can change carries a snapshot of it at that moment. A fact about immutable
content carries the digest and nothing more. The rule is the charter's, and the snapshot of an issue at each submit
is its first instance.

## Why

- A pluggable store, because an organization that already has an attestation store should not be given a second
  one, and one that has none should not need a service to start.
- A hidden ref as the shipped store, because git is the one substrate every provider shares, a ref outside the
  branches triggers nothing and is fetched by nothing by default, and a person can read it with the tools they have.
- Signed on the desk, because a record that only the store could vouch for is a record that the store's
  compromise erases, and a signature made where the act happened survives it.
- An issue's version as a snapshot at submit and not at every edit, because a typo fixed should not void a triager's
  verdict, and because the substantive answer to a request often arrives as a comment, which is no edit at all. The
  submit is the one act that says the proposer is ready to be judged again.

## Consequences

- Guiding and repairing reads the record's missing entries; observing reads its times.
- The mapping tables of jig-004 say, per provider, which of its facts a record may cite as evidence.
- The signing key a desk uses, and how a reader verifies it, belong with identity on a desk, which jig-001 leaves
  to its own RFC.

## Open questions

- Whether a record is one commit per transition or one per tick, batched.
- How far back a desk reads on first contact with a repository whose ref is long.
- Whether the shipped store also writes each record as a comment on the provider, so a person without jig can see
  it.

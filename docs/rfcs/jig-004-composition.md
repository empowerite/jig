# Composition: several providers, moving between them

Status: draft

## Decision

A type of [jig-001-types.md](jig-001-types.md) declares a location, a port and a place in it, and a provider-backed
type may declare one location per role: `origin`, where an instance is born; `work`, where the loop runs; `report`,
where status is told. An instance is then bound to several providers at once, one binding per role. The bindings are
the repository's own declaration in the chain, and composition is bindings plus roles: it needs no mechanism the model
does not already have.

### One fact, one owner

Each fact of an instance has one authoritative provider, by role. The origin owns the item's text, its acceptance
and its resolution as a person sees them; the work provider owns the changes and their lifecycle; the report
provider receives and never decides. A fact read from a provider that does not own it is a projection, and the
engine writes it back to the owner never and to the others as a mirror.

### The drip

When `origin` and `work` differ, an instance filed in the origin is mirrored into the work provider by a silent
transition: the engine observes a new instance in the origin and takes the type's creating action through the work
port, carrying the identity into both. From then on the loop runs in the work provider, and each state change is
written to the report provider as a comment, a field or a state, whatever the port's slot is. The instance resolves in
the origin when it resolves in the work provider, and never the other way.

### The drain

Moving a repository between hosts is composition run as a transition:

1. Add the new provider's ports beside the old, and mirror the repository, which git does.
2. The repository's policy shifts `origin` and `work` to the new provider for instances filed from now on.
3. Work in flight keeps its bindings and finishes where it started; the engine evaluates policy per item, on that
   item's bindings, so a mixed population is ordinary.
4. When no instance in flight binds to the old provider, its locations are removed from the repository's policy.
   History stays where it was, and the identity in every mirrored object says what corresponded to what.

Nothing stops and nothing is lost, because no item ever depended on which provider was the repository's.

### The proof

A second work port, Azure DevOps or Linear, dripping into GitHub, and a second change host, GitLab, receiving a
drain from GitHub, each on scratch repositories, each proven by the live suites of
[jig-003-ports.md](jig-003-ports.md). The abstraction holds when both run and nothing in the engine changed.

## Why

- Roles and not products, because a policy that said "GitHub" would have to be rewritten to say "GitLab," and a
  policy that says "work" does not.
- One owner per fact, because two providers each believing they own the state is the split brain every mirror
  eventually suffers.
- The drain as ordinary composition, because a migration that needs its own machinery is one nobody rehearses
  until the day it must work.
- A location per role rather than a second model, because a binding is already how an instance is known to a provider,
  and a type that can name one location can name three.

## Consequences

- Ports declare which roles they can play; `jig policy check` refuses a role a port cannot fill.
- The identity of `jig-001` is what survives a drain; provider numbers are bindings and change.
- The interface of `jig-006` shows an instance's bindings, so a person sees where each thing lives.
- Bindings are declared by the repository's own policy and by no link above it, as the chain of `jig-001` has it.

## Open questions

- Which provider owns `accepted` when origin and work differ: the origin's person, or the work provider's, or
  either.
- The form the identity takes in a provider without a body: a tag, a custom field, a comment.

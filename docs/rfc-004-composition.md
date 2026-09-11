# Composition: several providers, moving between them

Status: draft

## Decision

A work item may be bound to several providers at once, and policy names each provider's role: `origin`, where work
is born; `work`, where the loop runs; `report`, where status is told. Composition is bindings plus roles, and it
needs no mechanism the model of [rfc-001-types.md](rfc-001-types.md) does not already have.

### One fact, one owner

Each fact of a work item has one authoritative provider, by role. The origin owns the item's text, its acceptance
and its resolution as a person sees them; the work provider owns the changes and their lifecycle; the report
provider receives and never decides. A fact read from a provider that does not own it is a projection, and the
engine writes it back to the owner never and to the others as a mirror.

### The drip

When `origin` and `work` differ, a work item filed in the origin is mirrored into the work provider by a silent
transition: the engine observes a new item in the origin and creates its counterpart, carrying the identity into
both. From then on the loop runs in the work provider, and each state change is written to the report provider as
a comment, a field or a state, whatever the port's slot is. The item resolves in the origin when it resolves in
the work provider, and never the other way.

### The drain

Moving a repository between hosts is composition run as a transition:

1. Add the new provider's ports beside the old, and mirror the repository, which git does.
2. Policy shifts `origin` and `work` to the new provider for work items filed from now on.
3. Work in flight keeps its bindings and finishes where it started; the engine evaluates policy per item, on that
   item's bindings, so a mixed population is ordinary.
4. When no item in flight binds to the old provider, its ports are removed from policy. History stays where it
   was, and the identity in every mirrored object says what corresponded to what.

Nothing stops and nothing is lost, because no item ever depended on which provider was the repository's.

### The proof

A second work port, Azure DevOps or Linear, dripping into GitHub, and a second change host, GitLab, receiving a
drain from GitHub, each on scratch repositories, each proven by the live suites of
[rfc-003-ports.md](rfc-003-ports.md). The abstraction holds when both run and nothing in the engine changed.

## Why

- Roles and not products, because a policy that said "GitHub" would have to be rewritten to say "GitLab," and a
  policy that says "work" does not.
- One owner per fact, because two providers each believing they own the state is the split brain every mirror
  eventually suffers.
- The drain as ordinary composition, because a migration that needs its own machinery is one nobody rehearses
  until the day it must work.

## Consequences

- Ports declare which roles they can play; `jig policy check` refuses a role a port cannot fill.
- The identity of `rfc-001` is what survives a drain; provider numbers are bindings and change.
- The interface of `rfc-006` shows an item's bindings, so a person sees where each thing lives.

## Open questions

- Which provider owns `accepted` when origin and work differ: the origin's person, or the work provider's, or
  either.
- The form the identity takes in a provider without a body: a tag, a custom field, a comment.

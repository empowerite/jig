# Extensions: extension points, what they expose

Status: draft

## Decision

An extension is a separate executable named `jig-<name>`, declared in the repository's policy and never discovered
by scanning a path. jig starts it when the policy names it, speaks to it over a JSON protocol on its standard
streams, and stops it when the tick ends. It runs in its own process, in any language, and it sees the public
model of [0001-world-model.md](0001-world-model.md) as the schema of [0005-operator-surface.md](0005-operator-surface.md) publishes
it, and nothing else.

### The points

An extension attaches at fixed points, and a point is a typed contract:

- A gate: a verdict source. Given a change and its tree, it returns a verdict, keyed by tree, with artifacts.
  A review by a model, a policy check no provider runs, a cost estimate.
- A hook: before or after a transition. It may refuse a transition before it is taken, with a reason, and it may
  act after one is taken. It cannot take one.
- A presenter: a new surface over the same API, a chat integration, a status page.
- A port: a provider jig does not ship, written to the contract of [0002-ports.md](0002-ports.md) and proven by its own
  conformance suite before policy may name it.
- A brief source and a rule source: the two points [0008-jig-context.md][0008] and [0007-jig-discovery.md][0007]
  attach to, which is the test of this spec: if the seam cannot carry those two, it is the wrong seam.

### What it sees

The public model, the verbs, the events of the tick it runs in, and the policy's own section for it. It does not
see the engine's internal API, a provider's client or token, another extension, or jig's own facts except the
identity written into provider objects, which any reader of the provider sees anyway.

### The handshake

On start, the extension states its name, the version of the schema it was written against, and the points it
serves. jig refuses an extension whose schema version it does not serve, by name and version, before the tick.

### Installation and versions

An extension is installed the way jig is, by `mise`, and pinned the same way. Its version rides in the policy
beside its name. `jig doctor` reports every declared extension it cannot start.

## Why

- A separate process, because an extension in jig's own process is an extension in jig's own memory, and "careful
  what we expose" has no meaning once the internals are one pointer away.
- Declared and not discovered, because a binary that runs by being on a path is a binary nobody decided to run.
- Fixed points, because an extension that may attach anywhere is a fork in disguise, and a fork is what the
  charter's "not a workflow language" rules out for policy and this rules out for code.
- The two first extensions as the test, because they are the two jig needs to develop itself, and a seam that
  cannot carry what jig itself needs is not a seam.

## Consequences

- `jig-discovery` and `jig-context` are written against this spec and change nothing in the engine.
- The schema version becomes a fact every extension names, so a schema change is a release that can count what it
  breaks.
- The policy of [0003-policy.md](0003-policy.md) gains a table naming each extension, its version and its point.

## Open questions

- The protocol's shape: JSON-RPC over stdio, or the same GraphQL schema over a local socket. The first is simpler
  to write an extension against; the second is one contract instead of two.
- Whether a gate extension may run on a runner as a check, so that a provider reports its verdict, or only in a
  tick.

[0007]: https://github.com/empowerite/jig/issues/12
[0008]: https://github.com/empowerite/jig/issues/13

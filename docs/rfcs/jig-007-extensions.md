# Extensions: extension points, what they expose

Status: draft

## Decision

An extension is a separate executable named `jig-<name>`. Being on the `PATH` gives it its verb: `jig <name>` runs
`jig-<name>`, the way `git ls` runs `git-ls`, with the rest of the line passed through. Being named in the
repository's policy gives it its seat: jig starts it inside a tick only when the policy names it, speaks to it over a
JSON protocol on its standard streams, and stops it when the tick ends. It runs in its own process, in any language,
and it sees the public model of [jig-001-types.md](jig-001-types.md) as the schema of
[jig-006-operator-surface.md](jig-006-operator-surface.md) publishes it, and nothing else.

### The points

An extension attaches at fixed points, and a point is a typed contract:

- A gate: a verdict producer. Given a subject at a digest, it returns the verdict record of
  [jig-001-types.md](jig-001-types.md), keyed by the gate and the digest, with its evidence. A review by a model, a
  policy check no provider runs, a cost estimate. Beside its executable, a gate extension may ship rule gates,
  predicates in the decision language of [jig-002-language.md](jig-002-language.md) over facts jig already holds,
  which the engine evaluates in the guard without starting a process.
- A hook: before or after a transition. It may refuse a transition before it is taken, with a reason, and it may act
  after one is taken. It cannot take one.
- A presenter: a new surface over the same API, a chat integration, a status page.
- A port: a provider jig does not ship, written to the contract of [jig-003-ports.md](jig-003-ports.md) and proven by
  its own conformance suite before policy may name it.
- A brief source: the point [jig-008-jig-context.md](jig-008-jig-context.md) attaches to.
- A dispatcher: given the needs jig publishes, it starts an actor in a harness with the instance's brief, and reports
  what it started. It takes no transition; the actor it started takes them, as itself. jig starts no actor, so the
  dispatcher is outside the engine and inside the seam.

```json
// jig-007: a gate extension's request, on its stdin
{"subject": {"type": "rfc", "identity": "003", "digest": "blob:5e21a0f…"}}
```

```json
// jig-007: the verdict it returns, on its stdout: the record of jig-001, keyed by this gate and digest
{"gate": {"name": "links", "link": "./policy.cue", "digest": "sha256:e07a…"}, "conclusion": "pass",
 "evidence": {"annotations": [], "artifacts": [], "remedy": ""},
 "evaluator": {"tool": "lychee", "version": "0.24.0"}}
```

```json
// jig-007: a hook refusing a transition before it is taken, with a reason
{"transition": "accept", "subject": {"type": "rfc", "identity": "003"}, "refused": true,
 "reason": "no second maintainer has reviewed this rfc"}
```

```text
$ jig claude --once
started work item 42, worktree worktrees/42-slug, claude-code session 8f1c2d3a
```

The brief source and the dispatcher are the test of this spec: they are the two jig needs to develop itself with
agents, and if the seam cannot carry them it is the wrong seam.

### What it sees

The declared types as the schema publishes them, the verbs, the events of the tick it runs in, the brief of the
instance at hand, and the policy's own section for it. It does not see the engine's internal API, a provider's client
or token, another extension, or jig's own facts except the identity written into provider objects, which any reader of
the provider sees anyway.

### The handshake

On start, the extension states its name, the version of the schema it was written against, and the points it
serves. jig refuses an extension whose schema version it does not serve, by name and version, before the tick.

### Installation and versions

An extension is installed the way jig is, by `mise`, and pinned the same way. Its version rides in the policy
beside its name. `jig doctor` reports every declared extension it cannot start.

```cue
// jig-007: the policy stanza that seats an extension, named, pinned by version, at its point
extensions: "model-review": {version: "v0.4.0", point: "gate"}
```

## Why

- A separate process, because an extension in jig's own process is an extension in jig's own memory, and "careful
  what we expose" has no meaning once the internals are one pointer away.
- A verb from the `PATH` but a seat only from policy, because a person may run whatever they installed, and a
  tick may run only what the repository decided; a binary that acts in the engine by being on a path is a binary
  nobody decided to run.
- Fixed points, because an extension that may attach anywhere is a fork in disguise, and a fork is what the
  charter's "not a workflow language" rules out for policy and this rules out for code.
- The brief source and the dispatcher as the test, because they are the two jig needs to develop itself with agents,
  and a seam that cannot carry what jig itself needs is not a seam.
- A dispatcher as an extension and never a part of the engine, because jig starts no actor: a jig that started
  sessions would own a process it cannot see, and who acts on a need is not its decision.

## Consequences

- `jig-context` is written against this spec and changes nothing in the engine; a desk runs it as `jig context <N>`.
- jig ships one reference dispatcher, for one harness, released and pinned like any extension: the proof of the seam,
  and the one jig's own repository needs to develop itself with agents. Every other dispatcher is written by whoever
  runs the agents.
- The schema version becomes a fact every extension names, so a schema change is a release that can count what it
  breaks.
- The repository's policy names each extension, its version and its point, and a rule gate an extension ships is
  attached to a guard like any gate of [jig-001-types.md](jig-001-types.md).

## Open questions

- The protocol's shape: JSON-RPC over stdio, or the same GraphQL schema over a local socket. The first is simpler
  to write an extension against; the second is one contract instead of two.
- Whether a gate extension may run on a runner as a check, so that a provider reports its verdict, or only in a
  tick.

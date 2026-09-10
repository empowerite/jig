# Operator surface: CLI, API, GUI

Status: draft

## Decision

jig ships as one binary, `jig`, written in Go, with the browser interface compiled from TypeScript at release time
and embedded in it. A desk installs it through `mise`; a runner gets it through an action. Nothing else is
installed anywhere: Node exists in this repository as a build dependency of the release and nowhere else, and a
`nogui` build drops the embedded interface for a runner that wants a smaller file.

### The verbs

The command line is the transition relation of [0001-world-model.md](0001-world-model.md), one verb per
transition an actor takes, every one addressed by the number the provider gave the object:

- `jig file`, `jig accept`, `jig reject`, `jig park`, `jig take`: the work item's transitions and its attributes.
- `jig draft`, `jig propose`, `jig land`: the change's acted transitions.
- `jig tick`, board-wide, and `jig tick --item <N>`: one evaluation, as in [0004-engine.md](0004-engine.md).
- `jig board`: the view, as a table; `jig show <N>`: one item with its changes, verdicts and bindings.
- `jig policy check`, `jig policy plan`: as in [0003-policy.md](0003-policy.md). Beside them, `jig policy set
  <key> <value>`, `jig policy unset <key>` and `jig policy explain <key>`: the first two edit `jig.toml` in the
  working tree, run the check and print the plan in the same breath, and commit nothing; the third says what a
  key means and which values the ports actually offer. They are conveniences over the file, and the file, edited
  by hand, stays the truth.
- `jig rules <path>` and `jig brief <N>`: the two extensions of [0007-jig-discovery.md][0007] and
  [0008-jig-context.md][0008].
- `jig init`, which writes the first `jig.toml` from what the ports find; `jig doctor`, which reports every port's
  reachability, the toolchain, the signing setup and the version; `jig ui`, which serves the interface.

Every verb answers in plain text for a person and in JSON with `--json` for a program; on a runner, a refusal is
also a `::error::` annotation. A verb never renders jig's identity; every table speaks provider numbers.

### The API

The public contract is one GraphQL schema, derived from the model and committed as a file. `jig ui` serves it on
the desk's loopback interface; a future service serves the same schema remotely. Queries read the view;
subscriptions stream the events a tick produces; mutations are the verbs. Nothing reaches the interface, or any
other client, that is not in the schema, and the schema is versioned with the lifecycle.

### The MCP server

`jig mcp` exposes the verbs as tools and the view as resources to an agent harness, over the standard transport.
An agent calls jig; jig never calls an agent. The tools are the same functions the command line runs.

### The interface

The embedded interface is the board, the item, and the animation: what a tick observed and did, transition by
transition, as it happens, fed by the subscription. It draws only the lifecycle of the model, which is fixed, so
it never needs to learn a repository's states; it learns its gates and attributes from the policy it reads through
the same API.

### Exposure

Three presenters, the command line, GraphQL and MCP, sit on one internal API in Go. The presenters are thin; the
internal API is where behavior lives, and it is not public. An extension, [0006-extensions.md][0006], sees the
schema and the verbs, never the internal API.

## Why

- One binary, because "consumed by anyone" and "works without babysitting" both fail the moment a repository must
  adopt a toolchain to run its SDLC.
- The verbs as the transition relation, because a transition a person cannot take by hand is one they cannot
  understand, and a machine that takes it is then doing something no person could check.
- The schema as the contract, because a file everyone can read is the only honest answer to "what do we expose,"
  and a GUI that can only reach what the file names is a GUI that cannot leak an internal.
- Loopback for the desk, because the desk's data is the desk's; a remote service is a deliberate later choice
  with its own spec.

## Consequences

- The GUI is a client of the same API a third party would use, so the boundary is tested by jig's own interface
  every day.
- `mise.toml` in this repository pins the Go and Node toolchains the release needs; a consumer pins only `jig`.
- The docs pages install and use are written against these verbs.

## Open questions

- Whether `jig land` exists as a person's verb at all, or a person lands only through the provider's own button,
  with jig's landing reserved to the batch. The policy's actor table decides per repository; the verb exists so
  that the choice is available.
- The service host: when, and whether it is this binary with a flag or a separate spec.

[0006]: https://github.com/empowerite/jig/issues/11
[0007]: https://github.com/empowerite/jig/issues/12
[0008]: https://github.com/empowerite/jig/issues/13

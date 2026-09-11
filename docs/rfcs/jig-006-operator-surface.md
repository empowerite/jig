# Operator surface: CLI, API, GUI

Status: draft

## Decision

jig ships as one binary, `jig`, written in Go, with the browser interface compiled from TypeScript at release time
and embedded in it. A desk installs it through `mise`; a runner gets it through an action. Nothing else is
installed anywhere: Node exists in this repository as a build dependency of the release and nowhere else, and a
`nogui` build drops the embedded interface for a runner that wants a smaller file.

### The verbs

The command line is the transition relation of the types the policy declares, verb first and generic over every type,
with the type word dropped for the standard types where the id form is unambiguous.

- `jig new <type> [parameters]`: the creating action the type declares. Its parameters are the template's variables,
  read from the declaration; given on the command line they fill in, absent they are asked for. `jig new type <name>`
  is the same verb on the standard type named type, whose instances are declarations in the repository's policy, so a
  new type exists when its declaration lands through the loop and not when the prompt finishes.
- `jig list <type>` and `jig show <type> <id>`: the view, an instance with its state, its verdicts and its bindings.
  `jig board` is the standard read, the work items and changes as a table. `jig show 42` stays, since a bare number is
  a work item.
- `jig explain <type>`: the declaration as prose, the location, the name rule, the shape, the lifecycle and the gates,
  rendered from the policy that enforces them, for a person or an agent.
- The transitions, one verb per acted transition of each type's lifecycle, addressed by the number the provider gave
  the instance: `jig accept 42`, `jig propose 42`, `jig accept rfc 003`. Setting an attribute is a verb. Editing an
  instance's text is never jig's. There is no delete verb: deleting is a provider act jig observes, or a terminal
  transition the lifecycle declares.
- `jig verify [<id>]`: produce the verdicts the next transition of the change at hand is missing, here, now, through
  the gate port of [jig-003-ports.md](jig-003-ports.md), and report each.
- `jig tick`, board-wide, and `jig tick --item <N>`: one evaluation, as in [jig-005-engine.md](jig-005-engine.md).
- `jig policy check` and `jig policy plan`: as in [jig-001-types.md](jig-001-types.md) and
  [jig-002-language.md](jig-002-language.md).
- `jig context <N>`: the brief, the extension of [jig-008-jig-context.md](jig-008-jig-context.md). Any `jig-<name>` on
  the `PATH` runs as `jig <name>`, with the rest of the line passed through, and an unknown verb is looked up that way
  before it is refused; see [jig-007-extensions.md](jig-007-extensions.md).
- `jig init`, which writes the first policy from what the ports find; `jig doctor`, which reports every port's
  reachability, the toolchain, the signing setup and the version; `jig ui`, which serves the interface; `jig mcp`,
  which serves the tools.

Every verb answers in plain text for a person and in JSON with `--json` for a program. On a runner a refusal is also a
`::error::` annotation, and every refusal names the rule that fired and the facts it read. A verb never renders jig's
identity; every table speaks provider numbers.

### The API

The public contract is one GraphQL schema, derived from the declared types and committed as a file. `jig ui` serves it
on the desk's loopback interface; a future service serves the same schema remotely. Queries read the view;
subscriptions stream the events a tick produces; mutations are the verbs, so each verb above is a query or a mutation
over the schema, and an agent over MCP and a person at the command line use one declaration. Nothing reaches the
interface, or any other client, that is not in the schema, and the schema is versioned with the model.

### The MCP server

`jig mcp` exposes the verbs as tools and the view as resources to an agent harness, over the standard transport.
An agent calls jig; jig never calls an agent. The tools are the same functions the command line runs.

### The interface

The embedded interface is the board, the item, and the animation: what a tick observed and did, transition by
transition, as it happens, fed by the subscription. It draws whatever lifecycle the policy declares, as a graph, and
learns a repository's gates and attributes from the policy it reads through the same API.

### Exposure

Three presenters, the command line, GraphQL and MCP, sit on one internal API in Go. The presenters are thin; the
internal API is where behavior lives, and it is not public. An extension,
[jig-007-extensions.md](jig-007-extensions.md), sees the schema and the verbs, never the internal API.

## Why

- One binary, because "consumed by anyone" and "works without babysitting" both fail the moment a repository must
  adopt a toolchain to run its SDLC.
- The verbs as the transition relation, because a transition a person cannot take by hand is one they cannot
  understand, and a machine that takes it is then doing something no person could check.
- The schema as the contract, because a file everyone can read is the only honest answer to "what do we expose,"
  and a GUI that can only reach what the file names is a GUI that cannot leak an internal.
- Loopback for the desk, because the desk's data is the desk's; a remote service is a deliberate later choice
  with its own spec.
- Verb first, because the charter says the verbs are the transitions, and a transition reads as a verb before its
  object.
- One mechanism over every type, because a type that needed verbs of its own would be a second surface to learn and a
  second one to keep in step.

## Consequences

- The GUI is a client of the same API a third party would use, so the boundary is tested by jig's own interface
  every day.
- `mise.toml` in this repository pins the Go and Node toolchains the release needs; a consumer pins only `jig`.
- The docs pages install and use are written against these verbs.
- `jig explain` renders through the template language of [jig-002-language.md](jig-002-language.md).
- A name rule that includes a sequence, the next free number, says so in its declaration, because `new` must compute
  the name and a regex alone cannot; the name rule of [jig-001-types.md](jig-001-types.md) gains that clause when it
  is next amended.
- A desk's `jig new` for a type the repository declares on the branch it stands on reads the working tree's policy for
  the repository's own types, while the chain above stays pinned; the base-policy rule of
  [jig-005-engine.md](jig-005-engine.md) is about admission, not about what a desk may create.

## Open questions

- Whether `jig land` exists as a person's verb at all, or a person lands only through the provider's own button,
  with jig's landing reserved to the batch. The policy's actor table decides per repository; the verb exists so
  that the choice is available.
- The service host: when, and whether it is this binary with a flag or a separate spec.
- Whether conveniences that edit the policy file, the old `set` and `unset`, are wanted once the file is CUE, or
  whether the file edited by hand is enough.

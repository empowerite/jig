# Charter: what jig is and is not

Status: draft

## Decision

jig is a policy engine over declared entity types, and the software development lifecycle is the standard policy it
ships. A policy declares types:

- what an instance is
- where it lives
- what it may be called
- what it contains
- how it moves
- who may move it

jig reads every instance from the system that holds it. It computes the next legal move from the policy in force and
the facts it observed. It drives that move through the system's interface.

The work item and the change are the two types the standard policy declares. A work item is filed, assigned and
resolved. A change is drafted, submitted, admissible, integrating and integrated.

A repository declares types the same way, refining what is declared above it. A link above it — a team's or an
organization's — declares for every repository under it. jig owns none of the state it moves.

### The principles

1. Policy is declared. How an instance moves is data the repository commits, versions, and changes through the process
   the policy itself describes. Two clones at one commit run the same process, and a change to the process is reviewed
   like any other change.
2. Orchestration is a function call. The next legal move is computed from the policy and the observed state. Judgment
   is delegated to a named actor. Nothing else is left to interpretation, and no model is consulted where a function
   will do.
3. The state belongs to the systems that hold it. Work items, changes, reviews and verdicts live in the provider the
   repository already uses, and a person may act on them there. jig reconciles to what it observes. A merge made by
   hand is a transition someone else took, not an error.
4. Work moves without babysitting. Nobody needs to understand the machinery to keep work moving. Where a repository
   sets human gates, jig waits at them. Where it sets automated ones, the same machinery runs unattended.
5. A judgment carries its evidence. Every verdict names the gate, the subject at a digest, the policy in force and who
   produced it, and is signed. Anyone the repository answers to can verify it without jig.

### The parts

Each part has an RFC, and once accepted the RFC is the spec its code is checked against.

- Types, [jig-001-types.md](jig-001-types.md). A type is the unit of policy and declares six things:
  - an identity
  - a location
  - a name rule
  - a shape
  - a lifecycle
  - its actions
- Values, [jig-002-values.md](jig-002-values.md). A value is an instance of a type, read from wherever the type's
  location names, and judged against the type's name rule and shape from the moment it is read.
- Gates, [jig-003-gates.md](jig-003-gates.md). A gate judges one value at one version and yields a verdict — pass,
  fail or unknown — that names its subject, the policy in force and who produced it. It is signed, so it can be
  attested independent of jig.
- Lifecycles, [jig-004-lifecycles.md](jig-004-lifecycles.md). A lifecycle is the states a value may be in and the
  transitions between them. The kinds a state or a transition can be are fixed in jig itself and change only with a
  release; the lifecycle a policy builds from them is data it declares. Every gate in the standard policy repeats one
  fragment, two ground states and a derived annotation over the first.
- Policies, [jig-005-policies.md](jig-005-policies.md). A policy declares types with gates attached to their
  transitions' guards, and composes up a chain by pinned pulls, each link narrowing what the link above declared.
- Ports, [jig-006-ports.md](jig-006-ports.md). A port is the typed interface to a system jig does not own: the work
  tracker, the change host, the gates, the integrator, source control, the agent harness. Each has a fake for tests, a
  conformance suite against the real provider, and metrics in production.
- Composition, [jig-007-composition.md](jig-007-composition.md). An instance binds to several providers at once, one
  per role, and the same bindings move a repository between hosts while work is in flight.
- The engine, [jig-008-engine.md](jig-008-engine.md). One function from policy and view to actions, pure, tested as
  one, and generic over every lifecycle a policy declares. A tick calls it once and acts through the ports, for one
  work item or for the whole board.
- The language, [jig-009-language.md](jig-009-language.md). CUE declares and composes, Rego decides, Jinja2 renders
  every text jig emits, and all three are embedded in the binary.
- Extensions, [jig-010-extensions.md](jig-010-extensions.md). An executable named `jig-<name>` gets a verb by being on
  the `PATH` and a seat in a tick by being named in policy, at fixed points:
  - a gate
  - a hook
  - a presenter
  - a port
  - a brief source
  - a dispatcher
- The operator surface, [jig-011-operator-surface.md](jig-011-operator-surface.md). One binary. Its verbs are the
  transitions of the declared types, its GraphQL schema is the whole public contract, its MCP server is the same
  contract for agents, and its browser interface is embedded and used on a desk.
- jig context, [jig-012-jig-context.md](jig-012-jig-context.md). Actors — people, agent sessions, CI jobs and bots —
  do the work. jig briefs them and gates their moves. It starts none of them; a dispatcher that does is an extension.
- Release, [jig-013-release.md](jig-013-release.md). This repository runs on jig. A release is a tag carrying the
  binary, the reusable workflow, the schema and the standard policy, the last versioned apart from the binary.
- jigbot, [jig-014-jigbot.md](jig-014-jigbot.md). jigbot is the engine run board-wide as an actor of its own,
  optional, like an automated dependency updater.

### The boundaries

- jig is not a CI system. A gate is a command the repository declares or a check its provider runs. jig runs or
  triggers it through a port and reads the verdict. It defines no test and owns no runner.
- jig is not a ticket tracker. It binds to one. The work item's truth lives there, and anyone may edit it.
- jig is not an agent framework. An agent calls jig to learn where it stands, what it may do, and what a move
  requires. jig publishes needs, a repair wanted, an item unblocked. It does not prompt, choose a model, or dispatch,
  and who acts on a need is not its decision.
- jig is not a workflow language. A lifecycle is data within fixed kinds, declared and never programmed. A repository
  varies types, gates, actors, bindings and batch formation; the kinds and the capabilities change only with a
  release.
- jig is not a policy language. It declares in CUE and decides in Rego, and writes no evaluator of its own.
- jig is not the standard policy. The lifecycle it ships is one policy, pulled in as a link of the chain and versioned
  apart from the binary. A repository or an organization declares what the standard policy does not, and refines what
  it does.
- jig is not a git host. Git is the substrate every provider shares, and jig speaks to it directly.
- jig does not own your state. Whatever a person can see and change belongs to the provider. The few facts jig keeps
  have no human surface, and each is written back into a provider.

## Why

- jig is an engine over declared types rather than a control plane for one process. A lifecycle fixed in the binary
  would put every organization on jig's release cadence and could not give a platform component a lifecycle an
  application service does not have. The same engine that moves a change moves an RFC, a release or a deployment,
  with nothing added but a declaration. The SDLC is the standard policy because it is the one every repository needs
  and the one the ports are proven against first.
- Policy is declared because a process that lives in habit, in a wiki or in a person's head differs between two clones
  of one commit and cannot be diffed, reviewed or reverted. As data in the repository it is versioned with the code it
  governs and changed by the process it describes.
- Orchestration is a function call because a function is tested once and then trusted in every caller. It answers a
  person, a session and a bot alike, and needs no model. Judgment stays with a named actor, so what is delegated is
  explicit and what is computed is total.
- The state belongs to the systems that hold it because a person will act there anyway, and a second copy that could
  disagree with the first would have to win or lose. Reconciling to what is observed makes a hand-made merge a fact
  rather than a fault, and lets a repository leave a provider without leaving its history.
- Work moves without babysitting because a process that needs a person to remember the next step stalls when they
  forget, and a gate that needs a person to run it runs late. Waiting at a human gate and running an automated one are
  one machinery, so a person's attention goes to the judgment and to nothing else.
- A judgment carries its evidence because an audit asks what was in force and who said so, and a green check says only
  that a tool ran. A verdict that names its gate, its subject, the chain in force and its producer, and is signed, is
  a record anyone can verify. A record jig alone could verify would not be trusted outside jig.
- The boundaries are drawn where a system already exists. A repository has a tracker, a host, a CI system and a
  harness, and a second one of any of them would be a second owner of the same state. jig binds to them and adds the
  two things none of them has: the declared policy and the move computed from it.

## Consequences

- Every RFC's Why derives from a principle here and argues none of them again. jig-001 derives the type; jig-002
  the value; jig-003 the verdict; jig-004 the kinds; jig-005 the chain; jig-009 the languages; jig-006 the ports;
  jig-007 the bindings; jig-008 the engine and the tick; jig-011 the surface; jig-010 the extension points; jig-012
  the brief; jig-014 the bot; jig-013 this repository's own releases.
- README.md is install, setup and getting started. It says what jig is in one sentence and points here for the rest.
- This RFC is accepted before any other, since every other Why cites it. A change to a principle or a boundary is a
  change here first, and the RFCs that derive from it are corrected in the same change.

## Open questions

- Whether the fifth principle stands on its own or follows from the second and the third. It is listed because the
  verdict of jig-003 derives from nothing else here.
- Whether the RFC type this repository declares for itself becomes a second standard policy jig ships, and what else
  would.
- Whether a change's lifecycle needs a state beyond integrated. The charter once named one, realized; no other RFC
  defines it, so this decision drops the word until jig-004 or jig-013 settles what, if anything, follows integrated.

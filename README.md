# jig: a control plane for the software development lifecycle

jig is a control plane for the software development lifecycle. It declares how a change moves from a work item to a
landed and realized result, drives that movement across the systems a repository already uses, and shows people,
agents and bots one state. It owns none of that state.

## Why

jig rests on four principles.

1. An SDLC is declared. How work moves is policy: data the repository commits, versions, and changes through the
   process the policy describes. Two clones at one commit run the same process. A change to the process is reviewed
   like any other change.
2. Orchestration is a function call. The next legal move is computed from policy and observed state. Judgment is
   delegated to a named actor. Nothing else is left to interpretation, and no model is consulted where a function
   will do.
3. The state belongs to the systems that hold it. Tickets, pull requests, reviews and verdicts live in the provider
   the repository already uses, and a person may act on them there. jig reconciles to what it observes. A merge made
   by hand is a transition someone else took, not an error.
4. Work moves without babysitting. Nobody needs to understand the machinery to keep work moving. Where a repository
   sets human gates, jig waits at them. Where it sets automated ones, the same machinery runs unattended.

## The parts

- Policy is the SDLC a repository declares: which gates guard which transitions, who may take each, which provider
  path realizes each step, and how changes batch.
- The engine computes the next actions from policy and observed state. It is a pure function, runs with no network,
  and is tested as one. One evaluation is a tick, scoped to one work item or to the whole board.
- Ports are typed interfaces to the systems jig does not own: the work tracker, the change host, the gates, the
  source control host, the agent harness. Each port has a fake for tests, a conformance suite that runs against the
  real provider, and metrics in production.
- Actors are the people, agent sessions, CI jobs and bots that do the work. jig briefs them and gates their moves. It
  starts none of them.
- The operator surface is the command line, whose verbs are the transitions; a GraphQL schema, which is the whole
  public contract; an MCP server for agents; and a browser interface, built into the binary and used only on a desk.

## The lifecycle

jig owns one lifecycle and versions it with the code. A work item is filed, assigned, and resolved. A change is
drafted, proposed, admissible, integrating, integrated, and realized; admissible is the state from which it may
land, on its own or in a batch. A merge does not end the lifecycle. The verdict after integration does, once the
apply has run or the deployment is up.

Each provider realizes these steps in its own way: a draft pull request, a merge train, a build-validation policy. Its
port carries those paths. A repository chooses among them and attaches gates, actors and attributes. It cannot add a
state. A state jig lacks is a change to jig, made through a spec.

## Boundaries

- jig is not a CI system. A gate is a command the repository declares, such as `just test` on a desk or a pipeline on
  a runner. jig runs or triggers it through a port and reads the verdict. It defines no test and owns no runner.
- jig is not a ticket tracker. It binds to one. The ticket's truth lives there, and anyone may edit it.
- jig is not an agent framework. Agents call jig to learn where they are, what they may do, and what a path requires.
  jig publishes needs, such as a repair wanted or an item unblocked. It does not prompt, choose a model, or dispatch.
  Who acts on a need is not its decision.
- jig is not a workflow language. The lifecycle is fixed. A repository varies gates, attributes, port paths and batch
  formation. The shape changes only with a release.
- jig is not a git host. Git is the substrate every provider shares, and jig uses it directly.
- jig does not own your state. Whatever a person can see and change belongs to the provider. The few facts jig keeps
  have no human surface, and each is written back into a provider.

## Drivers

Every transition is a command, and three things issue them.

- A person types `jig` verbs, one item at a time, by the number the provider gave it.
- An agent session issues the same verbs over MCP and asks the questions only an agent asks.
- jigbot runs the board-wide tick. The repository's own CI hosts it, on events and on a schedule, and it holds the
  one durable view of the board, so no desk pays for that view twice. A repository may run jigbot or not, as it may
  run Dependabot or not. Without it, people and agents run the same verbs by hand.

## Composition and migration

A work item may bind to several providers at once: born in one tracker, worked in another, reported to the first.
Policy names port roles, not products. The same mechanism moves a repository between hosts while work is in flight:

1. Add the new port beside the old.
2. Start new work on the new port; let work in flight finish where it started.
3. Retire the old port when nothing binds to it.

## Status

Pre-alpha. The repository will run on jig as soon as jig can run it.

- `docs/` will describe how to install, use and extend jig, in the present tense.
- `specs/` will hold the design record: one numbered spec per part, each with a status line, written before the code
  and used to check it. When a spec and the code disagree, the spec is corrected or superseded.

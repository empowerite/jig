# jig

**A control plane for the software development lifecycle.** jig declares how a change moves from a work item to a
landed, realized result; drives that movement deterministically across the systems a repository already uses; and
keeps humans, agents and bots on one shared, observable state without owning any of it.

## Why

Four convictions, and the design is answerable to each:

1. **An SDLC is declared, not narrated.** How work moves is policy: data a repository commits, versions, and changes
   through the same process it describes. Two clones on one commit run the same process, and a change to the
   process is reviewed like any other change.
2. **Orchestration is a function call.** Which move is legal next is computed from policy and observed state,
   deterministically and cheaply. Judgment is delegated to actors by name; nothing else is left to interpretation,
   and no token is spent where a function would do.
3. **The state belongs to the systems that hold it.** Tickets, pull requests, reviews and verdicts live in the
   provider a repository already uses, where a human may act on them freely. jig reconciles to what it observes: a
   manual merge is not an anomaly but a transition someone else took.
4. **Velocity without babysitting.** Work moves without expert knowledge of the machinery. With human gates in place,
   jig waits at them; with minimal ones (an automated review, an agentic repair, an automated approval) the same
   machinery runs unattended.

## The parts

- **Policy**: the SDLC a repository declares. Which gates guard which transitions, who may take each, which provider
  path realizes each step, how changes batch.
- **Engine**: `next(policy, observed) → actions`. Pure, deterministic, testable with no network. A **tick** is one
  evaluation, scoped to a single work item or to the whole board.
- **Ports**: typed interfaces to what jig does not own. The work tracker, the change host, the gates, the SCM, the
  agent harness. Each is faked for tests, proven by a live conformance suite against the real provider, and
  instrumented in production.
- **Actors**: humans at a keyboard, agent sessions, CI jobs, bots. jig briefs and gates them; it never spawns one.
- **Operator surface**: the CLI, whose verbs *are* the transition relation; a GraphQL API that is the complete public
  contract; an MCP presenter for agents; and a browser GUI, embedded in the binary for a desk and inert on a runner.

## The lifecycle

One fixed lifecycle, owned by jig and versioned with it. A work item **exists**, is **committed to**; a change is
**authored**, **proposed**, **judged**, **integrated**, **realized**; the item is **resolved**. Merged is not done.
*Realized* is the post-integration verdict, the apply that ran, the deploy that landed, and it is what closes the loop.

Each provider realizes the steps its own way (a draft pull request, a merge train, a build-validation policy) and its
port ships those canonical paths. A repository chooses among them and attaches gates, actors and attributes. What it
cannot do is invent a state: a state jig lacks is a change to jig, argued in a spec.

## What jig is not

- **Not a CI system.** A gate is a command the repository declares, `just test` on a desk or a pipeline on a runner;
  jig runs or triggers it through a port and reads back the verdict. jig defines no test and owns no runner.
- **Not a ticket tracker.** It binds to one. The ticket's truth lives there, and anyone may edit it.
- **Not an agent framework.** Agents call jig, for where they are, what they may do, and what a path requires; jig
  publishes needs, a repair wanted or an item unblocked. It never prompts, never chooses a model, never dispatches.
  Who acts on a need is never its decision.
- **Not a workflow language.** The lifecycle is fixed. Variation lives in gates, attributes, port paths and batch
  formation, and the shape changes only by release.
- **Not a git host, and not a git replacement.** Git is the one substrate every provider shares, and jig speaks it
  directly.
- **Not the owner of your state.** Anything a human can see and touch belongs to the provider. jig's own facts are the
  few with no human surface, and every one of them is written back into a provider, so nothing is ever only jig's.

## How it works with you

Every state transition is a command. Three things drive them, over one engine:

- **A keyboard.** `jig` verbs, one item at a time, by the number the provider gave it.
- **An agent session.** The same verbs over MCP, plus the questions only an agent asks.
- **jigbot.** The board-wide tick, hosted by the repository's own CI on events and a schedule, holding the one durable
  view so that no desk pays for the board twice. Optional, the way Dependabot is optional: a repository without one
  has humans and agents running the same verbs by hand.

jig moves state; actors move code.

## Composition and migration

A work item may bind to more than one provider at once, born in one tracker, worked in another, reported back to the
first, because policy names port *roles* rather than products. The same mechanism moves a repository between hosts
with work in flight: the new port is added beside the old, new work originates there, in-flight work finishes where it
started, and the old port retires when nothing binds to it.

## Status

Pre-alpha, and bootstrapping: this repository runs on jig as soon as jig can run one.

- `docs/` will hold the experience: install, use, extend. Current-state description only.
- `specs/` will hold the decision record: one numbered design per part, with a status line, written before the code
  and held as what the code is checked against. When a spec and the code disagree, the spec is updated or superseded;
  it never silently rots.

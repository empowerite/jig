# World model and lifecycle

Status: draft

## Decision

jig keeps one model of the world, and the engine sees only that model. Every system jig drives, a work tracker, a
change host, a gate, a source-control host, an agent harness, is reached through a port that translates that
system's objects into the model's types and the model's actions back into that system's calls. Nothing below names
a provider; the ports do.

### The types

- A work item is a unit of intended work. It has an identity, a state in the lifecycle, attributes, relations to
  other work items, and bindings.
- A change is a proposed alteration of a repository, for one or more work items. It has a head, a base, its
  verdicts, its batch if it is in one, its realization once it has landed, and bindings.
- A verdict is the result of a gate over one tree. It is keyed by the tree it judged, not the commit, so a landing
  that mints a new commit over the same tree keeps its verdict. It carries a conclusion and any artifacts the gate
  produced.
- An actor is whoever takes a transition: a person, an agent session, a CI job, a bot. jig briefs actors and gates
  their moves; it starts none.
- A binding is a work item's or a change's counterpart in one provider: the provider, the role it plays, and the
  provider's own identifier and number. A work item may hold several bindings at once.
- A batch is an ordered set of admitted changes tested together as one speculative tree, with that tree's verdict.
- A realization is the verdict after integration: the apply that ran, the deployment that is up.

### Attributes and relations

An attribute is a fact a person sets on a work item or a change, stored in the provider and read by a port:
`accepted`, `rejected`, `parked`, `solo`, `priority`, `due`, and whatever else policy names. A relation is a fact
between two work items, `blocked by`, stored in the provider where it has a native form. Neither is a state.

### Identity

jig mints the identity of a work item and of a change. It is opaque, and it is never rendered in a table or offered
to a person; every verb, name and message uses the number the provider gave the bound object. The identity is
written into each bound provider object, in whatever slot that provider offers, so that the view below can be
rebuilt from the providers alone.

### The lifecycle

One lifecycle, jig's, versioned with the code.

A work item is in one of three states: it exists; it is committed to, an actor having taken it up; it is resolved.

A change is in one of five: authored, on a branch; proposed, as a pull request or its provider's equivalent;
judged, its gates having reported; integrated, landed on the default branch; realized, its post-integration verdict
green.

The transitions, and the gate on each:

| From | To | Gate |
| --- | --- | --- |
| exists | committed to | `accepted` is set and `parked` is not; an actor claims it |
| committed to | resolved | every change for it is realized, or policy says integrated suffices |
| authored | proposed | the actor proposes |
| proposed | judged | every gate policy names has reported |
| judged | integrated | every verdict is green, `parked` is not set, and the integrate path lands it |
| integrated | realized | the post-integration verdict is green |

A provider realizes each step in its own way, a draft pull request, a merge train, a build-validation policy, and
its port carries those paths, with sub-states of its own. Policy chooses among the paths and attaches gates, actors
and attributes. No repository adds a state. A state jig lacks is a change to this spec.

### Whose facts

- The provider's: anything a person can see and change there. A work item's title, state, attributes and
  relations; a change's reviews, verdicts and head. jig's copy is a projection, and when the two differ the
  provider is right; the difference is a transition someone took, not an error.
- jig's: the identity, the correspondence between a work item's bindings, the cursor per port, and the policy
  version in force. None has a human surface, and each is written back into a provider object.

### Freshness

The view is kept by reading each port's changes since a cursor, with a full resync on a schedule and on demand. It
is a cache. Losing it costs one resync and never a fact.

## Why

Each decision above follows from one of the charter's four principles.

- The engine sees only the model because orchestration is a function call: a function over a model is testable
  with no network, and a function over provider objects is not.
- The provider owns every human-visible fact because the state belongs to the systems that hold it. A person
  acting in the provider's own interface must never be an anomaly.
- Identity is jig's because composition and migration need a name that no provider owns: a work item born in one
  tracker and worked in another has two numbers and one identity.
- Identity is hidden because a person's vocabulary is the provider's number, and a second name in a table is a
  second thing to learn.
- Verdicts are keyed by tree because a landing may mint a new commit over the tree that was tested, and a verdict
  lost at that moment would force a second run for nothing.
- Attributes are not states because a person sets them freely, in the provider, at any time; a state is where the
  lifecycle puts a thing, and only a transition moves it.
- The lifecycle is fixed because every port must map to a known vocabulary, the interface must know what to draw,
  and a repository that could invent a state would be writing a workflow language.
- Realized exists because merged is not done. An apply that failed after a merge is a change that has not
  delivered, and a work item reporting done over it would be a false report.

## Consequences

- The public GraphQL schema is derived from the types above; nothing reaches the interface that is not here.
  See: `0005`.
- Every port implements, for the types it binds, three operations: read since cursor, resync, and act. See: `0002`.
- Policy names roles, paths, gates, actors and attributes over these types and nothing else. See: `0003`.
- The engine is `next(policy, view) → actions` over this model. See: `0004`.

## Open questions

- Where the inter-instance lease lives. Settled in `0004`.
- Which slot each provider uses for `due` and for the identity. Settled in `0002`, per port.
- Whether `realized` gates `resolved` by default or by opt-in. Settled in `0003`.

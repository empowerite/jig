# Lifecycles: state kinds, components, and the two gates every policy repeats

Status: draft

## Decision

A lifecycle is the states a value may be in and the transitions between them. The policy declares it; the kinds a
state and an act can be are fixed here. Deciding, in [jig-000-charter.md](jig-000-charter.md), computes over these
kinds and knows no state by name.

### States

A state's kind says who is responsible for acting while a value is there.

- An excited state has owners: a named set of actors obligated to act, and it ends when they do. Its name is a
  gerund, `proposing`, `approving`, `working`, `integrating`, and the owners are named with it.
- A grounded state has no owner. The value is at rest, and the state is the record of the transition that entered
  it: the version that transition bound, the verdicts it demanded, who produced them, and when. Its name is a
  participle, `approved`, `closed`, `integrated`.
- A derived state is a predicate over the facts on a value. It obligates nobody and is entered and left by
  observation. It appears in prose and on a board, `ready`, `landable`, `delivered`, and never as a state in the
  machine a policy declares: a transition does not care about its trigger.

### Transitions

- A transition is one move from one state to the next, by one actor, through one act, at one moment. It is taken
  through jig or observed elsewhere and mapped to its name; either way it is one transition.
- An act that deposits something is written with what it deposits: `submit(proposal)`, `approve(verdicts)`,
  `return(requests)`, `reject(reason)`, `abandon(reason)`. An act that deposits nothing stands bare: `retract`.
- `submit(proposal)` binds a version, the content of the value at that moment, and the verdicts that follow are
  keyed by it. A later submit binds a new version and voids every verdict on the old one, pass and fail alike.

### Components

A reusable lifecycle is a component: its internal states, its roles, one entry and its exits, and nothing outside
itself. An exit is named by the act that takes it, not by a state.

- The machine that instantiates a component binds each role to actors, binds the proposal to what a version is for
  that value, and binds each exit to one of its own states.
- It may alias the component's states and roles for display. The record keeps the canonical names under the
  instance's path, aliases are unique within the outer machine, and an alias never changes an exit's binding.
- Nesting is one level: a machine instantiates components, and a component instantiates none.
- Deciding runs the flattened machine; a component is a declaration's convenience and costs the runtime nothing.

### The process gate

The simplest component. One internal state, `processing`, owned by one role, the processor. One entry. Two exits,
`pass` and `fail`. A port merging a product and a pipeline deploying a release are its instances.

### The approval gate

The process gate refined: the processor splits into two roles and processing into two states.

- `proposing` is owned by the proposers. Their acts are `submit(proposal)`, which binds a version and obligates the
  approvers until they complete; `retract`, which takes the proposal back and releases the approvers; and
  `abandon(reason)`, their own exit.
- `approving` is owned by the approvers. Their acts are `approve(verdicts)`, the exit on the happy path, whose
  verdicts, each naming its producer and the version it judged, are the record's evidence; `return(requests)`, a
  request for clarification or rework that hands the proposal back to `proposing`; and `reject(reason)`, an exit.
- The entry is into `proposing`. The exits are `approve(verdicts)`, `reject(reason)` and `abandon(reason)`, and the
  outer machine binds each.

### Listing acts

Wherever a role's acts are listed, the order is the happy path in the direction of progress, then the happy path in
the direction of regress, then the unhappy path; among several of one kind, the more common first. So the
proposers are listed as `submit(proposal) · retract · abandon(reason)` and the approvers as
`approve(verdicts) · return(requests) · reject(reason)`.

## Why

- Kinds by responsibility, because the question every actor asks at every state is whether they are on the hook,
  and a kind that answered a different question, whether the content is mutable, would leave that one open.
- Derived states out of the machine, because a predicate over facts changes nobody's obligation, and a machine
  that carried it would have a state nobody is responsible for and nobody can leave on purpose.
- A transition indifferent to its trigger, because the record of a move is the same whether a person typed it, a
  session took it, or jig observed it after the fact; what differs is the actor, and the actor is recorded.
- Deposits written with the act, because the record is what the act carried, and a verb alone says nothing about
  what the record holds.
- Components with exits named by acts, because a component that named the states beyond its exits would decide
  the outer machine's vocabulary, and the same gate has to serve an issue, a pull request, a release and a promotion
  without knowing which.
- Canonical names under an alias, because a record that changed when a display name changed would be no record,
  and because the verbs a person types are the aliases while the audit reads the canonical path.
- Two gates and no third, because every gate a lifecycle needs is either something running to completion or
  someone judging something someone else made, and the difference between them is exactly one role and one state.
- `return` as a request and not a rejection, because a proposal handed back is still alive, and a lifecycle that
  could not tell rework from refusal would send the wrong thing to the wrong terminal.

## Consequences

- The standard machines of jig-003 are declared from these two gates and nothing else, and the figure that
  illustrates them is drawn to one grammar: the happy path down the center, what stops a value and what goes back
  on the left, what advances in on the right; an open dot for an entry and a solid dot for an exit; owners named
  inside excited states; acts colored by role.
- Presenting draws any declared lifecycle from its kinds, and the figure is the fixture its renderer is checked
  against.
- Mediating, in jig-004, maps an observed act to a transition here and never to a derived state.
- The verbs the command line offers are the acts of the instantiated components, under their aliases.

## Open questions

- Whether a derived state is declared in the policy, so a board can show it by name, or computed by presenting
  from facts alone.
- Whether roles are bound per instance of a component or once per type.
- Whether a grounded state may carry facts that change, an assignee, a priority, without ceasing to be a record of
  the transition that entered it. The standard machines assume it may.

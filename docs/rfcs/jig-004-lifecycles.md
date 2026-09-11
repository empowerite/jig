# Lifecycles: states and transitions on a type, the kinds the engine fixes, and the gate fragment

Status: draft

## Decision

A lifecycle is the fifth thing a type of [jig-001-types.md](jig-001-types.md) declares: the states a value of
[jig-002-values.md](jig-002-values.md) may be in and the transitions between them. The lifecycle is data, declared
by the policy that declares the type, and the kinds a state and a transition can be are fixed in the binary.

### The kinds

A state has one of three kinds.

- Ground: entered by an action and at rest until the next one. No silent transition leaves it.
- Derived: computed from facts. It holds while its condition holds, the engine enters and leaves it by observing, and
  it names something true of the value, such as admissible or flagged.
- Excited: an action under way, owned by the engine or a port. It decays on its own, into a ground state when the
  action completes, and on failure into a state that shows the failure.

A transition has one of two kinds.

- Silent: taken by observing. It carries a condition over facts and no actor.
- Acted: taken by an actor. It carries a guard, which is the gates of [jig-003-gates.md](jig-003-gates.md) whose
  verdicts must be pass on the value's current version and who may take it, and an action, which is a capability the
  type declares.

A gate attaches to an acted transition's guard and nowhere else. A guard reads verdicts and runs nothing; a verdict a
guard is missing is requested, and the transition waits.

Time is a fact, so a state that changes by the clock alone is derived or excited over that fact, and there is no
fourth kind. A state where a need is published is a ground state with a need attached, and need is a fact, not a kind.

A lifecycle is well formed when it has one initial state; every state has exactly one kind and is reachable; every
derived state has a condition; every excited state has a completion edge and a failure edge; every acted transition
names a capability its type declares; no silent transition leaves a ground state; and no failure lands back where it
started unmarked, so an excited state's failure edge leads to a state distinguishable from the one it left, or leaves
a verdict or a need on it that a derived state shows. `jig policy check` refuses a lifecycle that is not.

With those fixed, the engine's work at any state is one of three jobs, wait, compute or act, and a tick has one shape
whatever the lifecycle says: compute the derived states, take the enabled silent transitions, request the verdicts a
guard is missing, and queue the acted transitions whose guard is met and whose actor is this jig. The interface draws
whatever lifecycle is declared, as a graph.

### The gate fragment

Every gate in the standard policy is one fragment, repeated: two ground states and one derived state over the first.

- `submitted`, ground, entered by submit. A submit is the actor putting the value forward at its current version; for
  a change the submit is a push.
- `accepted`, ground, entered by accept. Its guard is a pass verdict on the current version, and its actor is whoever
  the policy names, a jigbot included. It is a commitment somebody took, and a later verdict on the same version does
  not undo it.
- `flagged`, derived over submitted. Its condition is that the latest verdict on the current version is not pass. Its
  remedy names who owes what: a need, when it names the submitter; the gate's owner, when the gate could not run.
- `withdrawn`, ground, entered by withdraw from submitted, flagged or not, by the submitter.

Resubmit is submit again. It advances the version, so every verdict on the old version is moot, pass and fail alike,
and flagged stops holding; nothing clears it. For a change the resubmit is a push. For a work item it is the submit
action, which advances the submission count; removing the projected label by hand is the same act, since the provider
owns the fact. A flag whose remedy is the gate's own clears when the gate writes a new verdict on the same version,
with no resubmit.

A label such as `work:flagged` is a projection of a state onto the provider, written by the engine when the state
starts holding and removed when it stops, so that a board and a provider's own filters see it. The engine never
trusts a label over the verdicts; where they disagree the tick rewrites the label.

Between two gates sits a ground state owned by an actor, where work happens, and the actor's submit enters the next
gate's `submitted`. A gate's `accepted` is never the next gate's `submitted`, because the two transitions have
different actors and the second is the one that binds a version.

```cue
// the standard change, cut to the states that show each kind, both transition kinds and the gate fragment
lifecycle: {
	initial: "drafted"
	states: {
		drafted:     kind: "ground"                                                  // entered by an action, at rest
		submitted:   kind: "ground"                                                  // the gate's entry; a push enters it
		flagged:     {kind: "derived", condition: "std.flagged"}                    // the latest verdict is not pass
		admissible:  {kind: "derived", condition: "std.admissible"}                 // holds while integrate's guard is met
		integrating: {kind: "excited", completes: "integrated", fails: "submitted"} // the merge under way; a fail verdict
		integrated:  kind: "ground"                                                  // makes flagged hold on failure
	}
	transitions: {
		submit:    {from: "drafted", to: "submitted", kind: "acted", action: "ready", actor: "author"}
		withdraw:  {from: "submitted", to: "drafted", kind: "silent", when: "input.change.draft"}
		integrate: {from: "admissible", to: "integrating", kind: "acted", action: "merge", actor: "maintainer"}
		integrate: gates: tests: run: "just test"
	}
}
```

The lifecycle of a type is declared by the link that declares the type. The standard lifecycle jig ships is the
default for the standard types.

## Why

- The kinds are fixed and the lifecycle is declared because the engine needs to know at a state whether to wait, to
  compute or to act, and nothing more; and because a lifecycle fixed in the binary put every organization on jig's
  release cadence and could not give a platform component a lifecycle an application service does not have.
- Time and need are facts rather than kinds because each kind is a different job for the tick, and a clock and a need
  are inputs to the same three jobs.
- A failure never lands back where it started unmarked because a failure that leaves no trace in the state graph is a
  failure nobody sees, and a value that fails and returns silently to the state that triggered the failure loops
  until someone happens to look.
- `submitted` and `accepted` are ground because each is entered by an act with an actor and a moment, which is what an
  attestation names, and `accepted` must survive later facts: a decision made is a record, not a condition.
- `flagged` is derived because a fail is a fact and not a decision anyone takes. A rule gate's fail is computed, a
  reviewer's request for changes is a provider fact keyed to the version, and both move the value without an actor,
  which only a derived state can. That also keeps the value in `submitted` underneath, where a resubmit is the same
  act as the first submit.
- One annotation rather than two, with the remedy doing the distinguishing, because a gate that could not run and a
  need the author owes look the same on a board and differ only in who has to act, and the remedy already says who.
- A label is a projection because a fact the provider's filters can see is worth writing, and a fact the engine
  trusted over its own verdicts would let anyone with label rights take a transition.

## Consequences

- The engine of [jig-008-engine.md](jig-008-engine.md) ticks over a declared lifecycle in the one shape above; see
  [#70][engine].
- The verbs of [jig-011-operator-surface.md](jig-011-operator-surface.md) are the declared acted transitions plus the
  engine's own; see [#72][surface].
- The standard policy of [jig-005-policies.md](jig-005-policies.md) builds every gate from the fragment above, and a
  link that refines a lifecycle may not add a state to it.
- The version rule of [jig-013-release.md](jig-013-release.md) changes, since the lifecycle is no longer in the
  binary; see [#75][release].
- The work port of [jig-006-ports.md](jig-006-ports.md) offers the submit capability for a work item, and its label
  writes are projections.
- A lifecycle is written in the form [jig-009-language.md](jig-009-language.md) fixes.

## Open questions

- Whether a silent transition may enter a ground state. The drip of jig-007 does, carrying the creating action, and
  the withdraw transition in the example above does by observing a person's act; the kinds say a ground state is
  entered by an action.
- How long a value may sit flagged before it is stale, whether stale is a derived state over the clock with a need
  published, and who takes the close that follows, the submitter, a triager or a jigbot.
- Whether a value in `accepted` whose content then changes re-enters `submitted` by a silent transition, or whether
  an accepted version is frozen and a change to it is a new value.

[engine]: https://github.com/empowerite/jig/issues/70
[surface]: https://github.com/empowerite/jig/issues/72
[release]: https://github.com/empowerite/jig/issues/75

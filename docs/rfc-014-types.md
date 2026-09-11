# Types: the unit of policy, the kinds the engine fixes, the chain, and the attested verdict

Status: draft

## Decision

jig is a policy engine over declared entity types. A policy declares types, and the engine is generic over what it
declares because the binary fixes the kinds a state and a transition can be and the capabilities a port can offer. The
work item and the change of the SDLC are two types jig's standard policy declares, and a repository declares types of
its own the same way. Policies compose up a chain by pinned pulls, each link narrowing what the link above declared.
Every evaluation of a gate yields a verdict that carries its provenance and can be attested. The charter in
[README.md](../README.md) states the principles this follows from and says that the lifecycle is data within fixed
kinds.

### The type

A type is the unit of policy. Every type declares six things.

1. An identity: how one instance is told from every other.
2. A location: a port and a place in it. A directory through the scm port, a tracker through the work port.
3. A name rule: what an instance may be called.
4. A shape: what an instance must contain.
5. A lifecycle: its states and the transitions between them, made of the kinds below.
6. Actions: what creates an instance and what moves it.

An instance is whatever the port reads at the location, and it is judged against the name rule and the shape from the
moment it is read. A file-backed type and a provider-backed type are one model, because a location is a port either
way. Work item and change are two declarations in the standard policy jig ships, with a provider behind each. A type
named rfc is the example a repository declares for itself: one directory, a name regex, a template as its shape from
which the creating action expands a new instance, and the states draft, accepted and superseded.

### The kinds

A state has one of three kinds.

- Ground: entered by an action and at rest until the next one. No silent transition leaves it.
- Derived: computed from facts. It holds while its condition holds, the engine enters and leaves it by observing, and
  it names a permission, such as admissible.
- Excited: an action under way, owned by the engine or a port. It decays on its own, into a ground state when the
  action completes or back to where it came from when it fails.

A transition has one of two kinds.

- Silent: taken by observing. It carries a condition over facts and no actor.
- Acted: taken by an actor. It carries a guard, which is the gates that must be green and who may take it, and an
  action, which is a capability the type's port offers.

The capabilities are a vocabulary jig names, and a port declares which of them it offers; which ones each port kind
offers is settled in [rfc-002-ports.md](rfc-002-ports.md). An acted transition names one. A gate attaches to an acted
transition's guard and nowhere else.

Time is a fact, so a state that changes by the clock alone is derived or excited over that fact, and there is no
fourth kind. A state where a need is published is a ground state with a need attached, and need is a fact, not a kind.

A lifecycle is well formed when it has one initial state; every state has exactly one kind and is reachable; every
derived state has a condition; every excited state has a completion edge and a failure edge; every acted transition
names a capability its type's port offers; and no silent transition leaves a ground state. `jig policy check` refuses
a lifecycle that is not.

With those fixed, a tick has one shape whatever the lifecycle says: compute the derived states, take the enabled
silent transitions, request the verdicts a guard is missing, and queue the acted transitions whose guard is met and
whose actor is this jig. The interface draws whatever lifecycle is declared, as a graph.

The lifecycle of a type is declared by the link that declares the type. The standard lifecycle jig ships is the
default for the standard types.

### The chain

A policy may pull in other policies. A pull names a policy and pins it by digest. The policies reachable from a
repository's own are its chain: the repository pulls in a team's, the team's pulls in an organization's, and any link
may pull in a published policy from a registry. `jig policy check` refuses an unpinned pull, and a change to a pin is
a change through the loop like any other.

Every link adds, and a default fills silence.

- A type is declared by exactly one link in the chain. Every link below it may refine the type and none may redeclare
  it.
- A refinement narrows. It may add a constraint to the name rule or the shape, attach a gate to a transition's guard,
  remove an actor from those who may take a transition, and add an attribute. It may not remove a state, a transition,
  a gate or a constraint, may not add an actor, and may not add a state or a transition to a lifecycle a link above
  declared.
- The standard types are declared by a link the repository pulls in, never by the repository's own policy. Where no
  link in the chain declares them, the standard policy is the default and fills the silence. A repository with no
  organization above it that wants a lifecycle of its own writes a second link and pulls it in; the chain is about
  position, not about an organization existing.
- A repository's own policy declares what is only its own: the types nobody above declared, with their lifecycles; its
  bindings, which provider plays which role; and the scripts its gates name.
- On a transition, the guard is the union of every gate any link attached, and the actors are the intersection of what
  every link allows. A refusal names the link its gate came from.

A contradiction is an error, and precedence never resolves one. Two links declaring the same type, a refinement that
widens, a pull that does not pin: `jig policy check` reports each, naming both sources, and the chain does not
evaluate until it is fixed. When a team publishes what an rfc is after a repository declared its own, that is two
declarations of rfc; the repository turns its declaration into a refinement of the team's or adopts the team's
outright, and its existing instances are then judged by the team's rules.

### The verdict

A verdict is the result of evaluating one gate over one subject, keyed by the gate's identity and the subject's
digest. The subject is an instance at a digest: a change's tree, an rfc's blob, a provider object at its version. A
new digest needs a new verdict. A gate whose own definition changed, which is a change in the digest of its link, has
stale verdicts; a change elsewhere in the chain leaves them standing.

Two producers yield one record.

- A rule gate is evaluated by the engine over facts it already holds, in the guard, at once.
- A verdict gate is run by something: a command on a desk, a check on the provider, an extension in a tick. The guard
  reads its result and never runs it.

Every verdict carries the subject, as type, identity and digest; the gate, by name and by the digest of the link that
declared it; the conclusion, which is pass, fail or unknown; the evidence, which is the annotations, the artifacts and
the remedy; the evaluator, which is jig's version for a rule gate and the tool and its version for a verdict gate;
every link of the chain in force, by digest; the time; and a signature by the actor that produced it, a person's key
on a desk and the bot's key for a jigbot.

An attestation is a verdict written as an in-toto statement and signed in the DSSE envelope, so that anything outside
jig can verify it. A transition taken is attested once more, as a statement naming the verdicts its guard required.
Both are stored through the port in the slot the provider offers: an attestation store keyed by digest where the
provider has one, a ref or a note where it does not, a comment last. The provider owns them, as it owns every other
fact.

Whether every aspect of the policy was applied to a subject is then a query and not a search: the transition's
statement, the chain digests it names, and the verdicts it names, each signed.

## Why

- The type is the unit of policy because a rule with no gate behind it is prose nobody writes, and a declared type has
  teeth and pays back: it refuses variance, expands its template, and answers what it is when asked. The rule and its
  documentation are one artifact, computed from the policy that enforces it.
- File-backed and provider-backed types are one model because a location is a port either way, and two models would be
  two engines.
- The kinds are fixed and the lifecycle is declared because the engine needs to know at a state whether to wait, to
  compute or to act, and nothing more; and because a lifecycle fixed in the binary put every organization on jig's
  release cadence and could not give a platform component a lifecycle an application service does not have.
- Time and need are facts rather than kinds because each kind is a different job for the tick, and a clock and a need
  are inputs to the same three jobs.
- Each link is a subtype of the link above it, and the rules of the chain are the variances of that relation. Value-
  like things narrow covariantly: the instances a type admits, the traces a lifecycle admits, the actors. Predicate-
  like things accumulate contravariantly: a gate or a constraint on a type binds every refinement of it, which is why
  an organization's gates reach every repository uncopied and can only be added to. On lifecycles the ordering is
  simulation, and the ban on adding a state or a transition is what preserves it. The substitutability preserved is
  the organization's, not the actor's: an actor refused where the parent would have allowed has lost a convenience,
  not a guarantee.
- A contradiction is an error because it is the bottom of that lattice, two constraints whose meet is empty, and a
  precedence would be a choice made silently by whoever placed a file nearer.
- Nothing removes and a default fills silence because a repository that could drop a gate by declaring something about
  itself could opt out of its organization's rule, and a default that only fills silence cannot be used to do so.
- A verdict is keyed by gate and subject digest because it is one judgment over one content, and any other key would
  let a stale judgment stand for a new content or a changed rule.
- A verdict carries the chain and a signature because an audit asks what was in force and who said so, and a check run
  says only that a tool ran.
- The statement format is in-toto in a DSSE envelope because a record only jig can verify is a record nobody outside
  jig can trust, and both are what existing attestation stores already hold.

## Consequences

- rfc-001, rfc-003, rfc-007, rfc-012 and rfc-013 are superseded by this RFC; see [the supersession][supersede].
- The ports of [rfc-002-ports.md](rfc-002-ports.md) gain the scm port as a location, the production of a verdict on
  request, and a slot per provider for attestations; see [#69][ports].
- The engine of [rfc-004-engine.md](rfc-004-engine.md) ticks over a declared lifecycle in the one shape above; see
  [#70][engine].
- The verbs of [rfc-005-operator-surface.md](rfc-005-operator-surface.md) are the declared acted transitions plus the
  engine's own, `jig verify` produces the verdicts a transition is missing, and the audit answer is a verb; see
  [#72][surface].
- The extension points of [rfc-006-extensions.md](rfc-006-extensions.md) lose the rule source, gain a dispatcher, and
  a gate extension returns the verdict record above; see [#71][extensions].
- The brief of [rfc-008-jig-context.md](rfc-008-jig-context.md) names the gates that will judge the paths a change
  touches; see [#73][context].
- The version rule of [rfc-010-release.md](rfc-010-release.md) changes, since the lifecycle is no longer in the
  binary; see [#75][release].
- The roles of [rfc-011-composition.md](rfc-011-composition.md) are bindings a repository declares; see
  [#76][composition].
- What a policy is written in, and how a published policy is packaged and pinned, is [rfc-015][language].
- This repository declares rfc as its first type, in its own policy, once the language exists, and the record rules of
  `docs/1st.md` become that declaration.

## Open questions

- Which capabilities each port kind offers, settled per port in rfc-002.
- Whose key signs a verdict and how a consumer verifies it; with releases, in rfc-010.
- What the in-toto statement's subject carries and what its predicate carries.
- Whether a link may ever mark a declaration as advisory, so that a link below may drop it. Deferred, not refused: it
  would be a marking on the upstream declaration and would not change the rules above.
- The identity of a file-backed instance across a rename or a move.

[supersede]: https://github.com/empowerite/jig/issues/68
[ports]: https://github.com/empowerite/jig/issues/69
[engine]: https://github.com/empowerite/jig/issues/70
[extensions]: https://github.com/empowerite/jig/issues/71
[surface]: https://github.com/empowerite/jig/issues/72
[context]: https://github.com/empowerite/jig/issues/73
[release]: https://github.com/empowerite/jig/issues/75
[composition]: https://github.com/empowerite/jig/issues/76
[language]: https://github.com/empowerite/jig/issues/67

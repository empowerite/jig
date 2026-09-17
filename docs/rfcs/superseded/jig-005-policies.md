# Policies: types with gates attached, the chain, and the organization's requirement

Status: draft

## Decision

A policy declares types of [jig-001-types.md](jig-001-types.md), each with its lifecycle of
[jig-004-lifecycles.md](jig-004-lifecycles.md), and attaches gates of [jig-003-gates.md](jig-003-gates.md) to the
guards of their transitions. Policies compose up a chain by pinned pulls, each link narrowing what the link above
declared.

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

```cue
// the organization's link, github.com/empowerite/policy: refines the standard change and narrows only
types: change: lifecycle: transitions: {
	submit:    gates: "signed-commits": rule: "std.signed_commits" // a gate added: every repository below carries it
	integrate: gates: tests: run: "just test"                     // a gate added, with the command that produces it
}

// the repository's link, ./policy.cue: pulls both in, and declares the same gate a second way
types: change: lifecycle: transitions: integrate: gates: tests: run: "make test"
```

```text
$ jig policy check
types.change.lifecycle.transitions.integrate.gates.tests.run: conflicting values "make test" and "just test":
    ./policy.cue:9:71
    github.com/empowerite/policy@v0.1.2/change.cue:4:41
```

### The requirement

A policy is itself a type, and a repository's policy is a value of it, at the digest of its link. An organization or
a team requires something of a repository not by writing a gate into the repository's chain but by declaring a gate
whose subject is the repository's policy: that it pulls a named published policy at a version in a range. Every rule
an organization wants applied is then a published, versioned policy, and the requirement names it.

- The gate is evaluated from outside. The organization's actor, a jigbot ticking the board of every repository it
  owns, judges each repository's policy, and a repository cannot decline a gate it never pulled.
- The gate is demanded where a guard names it. In the standard policy that is the promotion of a release into
  production, whose subject is the collection of artifacts at its digest, and the judgment there is a query over the
  attestations each artifact's landing wrote: whether the policy in force when it was built sits in the range. Each
  lower environment guards its own promotion with its own gates, and a repository that passes those gets in.
- Before it is demanded, the gate is computed and its verdict stored on every tick, and a fail is rendered as a
  warning naming the value, the transition that will refuse it and the remedy.
- Widening a range comes first and raising a floor second. Adding a major to the range leaves every repository green
  and lets each move when it chooses; dropping the old floor flags every repository still on it, with the remedy
  being the bump. A floor with a date on it is a need published ahead of time.

A published policy carries a version of its own, and a range is over versions. The repository still pins a digest,
within the range, and the digest is what the chain evaluates.

## Why

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
- The requirement is a gate over the repository's policy and not a link the repository pulls, because a pinned pull
  is the repository's act and an organization can require nothing through it; and because an organization edit that
  reached every repository at once, through a pull re-pinned everywhere, would be the big-bang change the range is
  there to avoid.
- The requirement is evaluated from outside because a gate the repository runs on itself is one the repository can
  stop running, and tamper-proof is a matter of where the gate is named and who evaluates it.
- The requirement is demanded at production and computed everywhere before it because the moment a team learns it is
  out of range should be the day the floor rises and not the day of the release, while a team's own environments are
  the team's to gate.

## Consequences

- What a pull is written in, and how a published policy is packaged, versioned and pinned, is
  [jig-009-language.md](jig-009-language.md).
- The roles of [jig-007-composition.md](jig-007-composition.md) are bindings a repository declares; see
  [#76][composition].
- The standard policy's release, in [jig-013-release.md](jig-013-release.md), is what a requirement names by
  version, and the promotion of a release into production is the transition that demands the requirement.
- The organization's actor of [jig-014-jigbot.md](jig-014-jigbot.md) is what evaluates a requirement, over every
  repository the organization owns.
- The warning a not-yet-demanded fail renders as is [jig-011-operator-surface.md](jig-011-operator-surface.md)'s to
  shape, in the log's own command where the log has one.

## Open questions

- Whether a link may ever mark a declaration as advisory, so that a link below may drop it. Deferred, not refused: it
  would be a marking on the upstream declaration and would not change the rules above.
- Whether an environment is a type the organization declares, with the promotion into it a transition on the release,
  or a named transition on the release's own lifecycle.
- What a published policy's version is, and where the registry that serves it by version lives.

[composition]: https://github.com/empowerite/jig/issues/76

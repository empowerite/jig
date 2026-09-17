# Charter: what jig is and is not

Status: draft

## Decision

jig keeps a software development lifecycle honest across the systems that hold it: the tracker, the code host, the
CI system, and the agent harness on a desk. It is made of six components. Each is jig's own, and none of them is
the whole.

- Deciding. From a declared policy and the facts it observes, jig computes which transitions are legal for a value
  and who may take each. While a value is in a state that has owners, the transitions belong to those owners, and
  jig takes none of them. It decides; it does not act for anyone.
- Recording. Every resting state a value reaches is written as the record of the transition that entered it: the
  version it bound, the verdicts it demanded, who produced them, and when. The record goes to an evidence store the
  repository chooses. A fact about a mutable entity carries a snapshot of the entity; a fact about immutable content
  carries its digest.
- Mediating. A transition taken through jig is checked against the policy first. A transition taken elsewhere, in
  the provider's own interface or command line, is observed, mapped to the policy's names, and admitted; jig neither
  prevents it nor undoes it. What jig does is notice what such a transition should have carried and did not, and say
  what would remedy it. Mediating is best-effort by design, and the gates that always run, continuous integration
  above all, are what keep policy and practice from drifting far.
- Presenting. One command line, one browser interface and one MCP server, over every checkout a desk has opened,
  each a view of the same policy and the same record. A person, a session and a program read one declaration.
- Guiding and repairing. An actor about to work on a value is handed what it needs: where the value stands, which
  moves are legal, and what each requires. Where a record is missing evidence or a verdict, jig names the corrective
  act, and takes it where the policy lets it.
- Observing. The measures that keep the work moving: how long a proposal has waited for its approvers against the
  limit the policy sets, how full a batch runs, where the queue stands. Observing reports; it decides nothing.

The standard policy jig ships is the software development lifecycle: a work order, a work product, a release and a
deployment, each with a declared lifecycle. A repository declares its own types the same way and refines the
standard ones.

### What jig is not

- jig is not a CI system. A gate is a command a repository declares or a check its provider runs. jig triggers it or
  reads its result, and owns no runner.
- jig is not a tracker and not a code host. It binds to the ones the repository uses, and the truth of an issue or a
  pull request lives there.
- jig is not an agent framework. An agent calls jig to learn where it stands and what it may do. jig prompts no
  model and starts no agent.
- jig is not a gatekeeper that fights people in their own tools. A person may act in the provider directly, and
  jig's answer is to observe, record and remedy, never to block or revert by default.
- jig does not own the state it moves. What a person can see and change belongs to the provider. What jig keeps is
  the record, and the record is evidence about the provider's state, never a second copy of it.

## Why

- Six components rather than one engine, because the questions a team asks of the machinery are six different
  questions. What may happen next is deciding. What happened, provably, is recording. What to do when someone acted
  outside the machinery is mediating. How to see it is presenting. What to do now is guiding. Whether the factory is
  running well is observing. A design that answers only the first has nothing to say to the other five, and the
  earlier series answered only the first.
- Deciding takes no transition of its own because the record is only worth trusting if every act in it has an
  actor, and a machine that acts in the owners' place erases the one fact the record exists to keep.
- Recording keeps a snapshot of a mutable entity because a fact about something that can change is worthless
  without the content it was a fact about, and keeps only a digest of immutable content because the content can
  always be fetched by it.
- Mediating is best-effort because people will use the provider directly whatever the machinery says, and a system
  that treats every such act as an error is one people route around. Observing and remedying is what a system that
  people keep using does, and the always-on gates are what make the drift bounded.
- Presenting is one declaration behind three surfaces because a person, a session and a program that see different
  things cannot agree on what to do next.
- Guiding is a component because the most expensive failure in a lifecycle is an actor who does not know what is
  expected of them, and repairing is its other half because the second most expensive is a gap in the record that
  nobody is asked to close.
- Observing is a component because a lifecycle policy is a claim about how work should flow, and a claim with no
  measurement behind it cannot be tuned.
- The boundaries are drawn where a system already exists. A repository has a tracker, a host, a CI system and a
  harness, and a second one of any of them would be a second owner of the same state. jig binds to them and adds the
  record, the decision and the guidance that none of them has.

## Consequences

- Every RFC after this one derives from a component here and argues none of them again. jig-001 is the runtime
  behind presenting; jig-002 and jig-003 are deciding's declarations; jig-004 is mediating; jig-005 is recording.
- README.md is install, setup and getting started. It says what jig is in one sentence and points here for the rest.
- This RFC is accepted before any other, since every other Why cites it. A change to a component or a boundary is a
  change here first, and the RFCs that derive from it are corrected in the same change.

## Open questions

- Whether the limits observing measures against are part of the policy, declared and versioned with it, or
  configuration a desk sets.
- Where the view across many desks lives. A desk presents its own checkouts; an aggregate across an organization
  is a later service, and this charter does not place it.

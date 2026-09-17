# Acts taken outside jig: observation, mapping, and the evidence they leave

Status: draft

## Decision

People act in the provider directly, in its interface and its command line, and jig cannot prevent it. Mediating,
in [jig-000-charter.md](jig-000-charter.md), is therefore an observer first. This RFC says what an observed act
becomes.

### Admission

- An act observed on the provider is admitted as the transition of [jig-002-lifecycles.md](jig-002-lifecycles.md)
  it corresponds to, with the actor the provider names and the version current at that moment. It is one
  transition like any other, and it is never undone.
- The mapping from the provider's events to the standard machines of [jig-003-machines.md](jig-003-machines.md) is
  part of the standard policy, one table per provider, and a repository may extend it for types of its own.
- An act with no transition to map to is a fact. An edit to an issue's body is a fact, and `edited since submitted`
  is derived over it.

### Evidence

- On admitting a transition, jig computes what the gate on it would have demanded at that version and looks for
  each verdict in the provider's own facts: a review left on that head, a check run against it, a label's timeline
  event with its actor. What it finds becomes the record's evidence.
- What it cannot find is written into the record as missing, with the remedy named and the owner of the remedy
  identified. A pull request merged by hand with no approving review is admitted as integrated, with the review
  recorded as missing.
- The provider's timeline names who applied a label, and an issue body's edit history is kept, so an edit after
  approval is detected by comparing the edit's time to the approval's.

### An actor outside the role

When the provider's actor for an act is not among those the policy names for it, a non-triager applying the label
that means approval, the policy chooses one of two behaviors per transition.

- Believe and mark: the act is admitted, the actor is recorded as outside the role, and the record shows it.
- Own and revert: the label is a projection jig owns; jig puts it back as the verdicts say, and records that it did.

The first is the default. The second is a repair action a policy switches on where a label is load-bearing.

## Why

- Admitted and never undone, because the state belongs to the provider, and a system that reverted what people did
  in their own tools is one they route around; the record, not the revert, is what jig has to offer.
- Evidence sought rather than demanded, because most of what a gate needs already exists in the provider by the
  time an act is observed, and a record that ignored it would call complete work incomplete.
- Missing evidence recorded rather than refused, because an observed act has already happened; the honest record
  says what it lacked and who can still supply it.
- Two behaviors for an outsider's act, because a label that only decorates and a label that gates deserve
  different treatment, and only the policy knows which a given label is.

## Consequences

- The provider ports carry the mapping tables, and a conformance suite exercises each row against the live provider.
- Guiding and repairing reads the record's missing entries and offers each remedy to its owner.
- Recording, in jig-005, gives an observed transition the same record shape as a taken one, with the actor's
  origin noted.

## Open questions

- How an act that cannot be mapped at all, a reopen of a closed pull request with a new head, is recorded.
- Whether believe-and-mark should also comment on the provider, so a person without jig sees the mark.

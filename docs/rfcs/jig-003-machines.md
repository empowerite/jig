# The standard machines: WorkOrder, WorkProduct, Release, Deployment

Status: draft

## Decision

The standard policy declares four types, each with a lifecycle built from the two gates of
[jig-002-lifecycles.md](jig-002-lifecycles.md) and nothing else. The names below are the canonical ones; a
repository may alias them for display. The figure at [figures/machines.svg](figures/machines.svg) draws each machine
and their couplings.

### WorkOrder

A WorkOrder is an issue: a proposal of work, judged once, then carried out by a product.

- The approval gate, with the issue's authors as its proposers and the triagers the policy names as its approvers.
  `proposing` is the issue being written where jig cannot see it; opening the issue is the first
  `submit(proposal)`, and version 1 is the issue as opened. `approve(verdicts)` binds to `scheduling`,
  `reject(reason)` to `rejected`, and `abandon(reason)` to `abandoned`.
- `scheduling`, owned by the schedulers: whoever is responsible for giving an approved order to a product. By
  default the role is played by the worker who picks the order up; a lead or a planner may play it instead. Their
  acts are `bind(workproduct)`, which binds the order to a product and moves it to `working`, and `cancel(reason)`,
  the exit into `cancelled`. Facts attach here, a priority, blockers, a milestone, and `ready` is derived over them.
- `working`, owned by the product's workers. The order takes no act of its own here. The product unbinding it
  returns it to `scheduling`; the product integrating moves it to `closed`; the product being abandoned or rejected
  returns it all the way to `proposing`, the state with the external entry, so the proposers decide what happens
  next.
- `closed` is terminal. `delivered` is derived over deployments: a release containing the landed product has a
  `deployed` instance in production.

### WorkProduct

A WorkProduct is a pull request: one or more approved orders packaged into a draft, carried to integration.

- `open(workorder)` by a worker starts it from a single approved order. The workers are its proposers, and while it
  is theirs they `bind(workorder)` and `unbind(workorder)`. A bind is the order's `bind(workproduct)` seen from the
  product; unbinding is the product's act alone. A product holds several orders; an order is held by one product at
  a time.
- The approval gate, with the reviewers and the checks the policy names as its approvers, over the head commit as
  the version. A push during `approving`, or a change of composition there, is `retract` then `submit(proposal)`.
  `approve(verdicts)` binds to `approved`, `reject(reason)` to `rejected`, `abandon(reason)` to `abandoned`, and an
  approved product may still be abandoned, by a worker or a maintainer as the policy names.
- `approved` rests because landing is a separate act by a different actor. `landable` is derived: approved, current
  with its base, and no hold.
- `land`, by a maintainer, enters a process gate, `integrating`, run by the port that merges. `pass` binds to
  `integrated`, terminal; `fail` returns the product to `proposing` with the reason.
- The product's `abandoned` and `rejected` return every order it holds to `proposing`.

### Release

A Release is a tag: a commit put forward for release.

- `cut`, by the release manager, enters `proposing` from a commit on the default branch or a release branch.
- The approval gate, with the release's checks, a sign-off where the policy demands one, and the organization's
  requirement on the policy in force as its approvers, over the commit as the version. `approve(verdicts)` binds to
  `released`, terminal; its facts are its deployments.

### Deployment

A Deployment is one release into one target, and a retry is a new instance.

- `promote`, by whoever the policy names, enters `approving`, owned by the target's approvers: its required
  reviewers, its wait, and the gates of the target below it. `reject(reason)` binds to `rejected`.
- `approve(verdicts)` enters a process gate, `deploying`, run by the pipeline the port drives. `pass` binds to
  `deployed`, terminal; `fail` to `failed`, terminal. `superseded` is derived: a later deployment to the same target
  has succeeded.

### The couplings

- `bind(workproduct)` on an order and `bind(workorder)` on a product are one act seen from each side.
- A product's `integrated` closes every order it holds; its `abandoned` or `rejected` sends each back to
  `proposing`.
- A release contains a landed commit or it does not; that is a fact of git.
- `delivered` holds on an order when a release containing its product has a `deployed` instance in production.
  Continuous delivery is never a state of the order.

## Why

- Four types and two gates, because everything the lifecycle judges is either a proposal someone approves or a
  process that runs to completion, and the four are the places the organization has decided to judge.
- An order is judged once and then carried, because the second judgment people reach for on an order, whether the
  work resolved it, is the product's judgment, and drawing it twice put the same gate on two machines.
- `scheduling` has an owner, because an approved order waiting with nobody responsible for it is how work is lost,
  and naming the role is what makes the wait visible.
- An order is bound to a product and not assigned to a person, because the product is what carries it, the person
  is a fact on the order that ready reads, and the two change at different times for different reasons.
- Unbinding is the product's act, because composition is the product's to manage while it is being proposed, and
  the order only observes.
- A product's failure returns its orders to `proposing` and not to `scheduling`, because a failed product is
  evidence that the proposal needs a proposer's judgment again, and `proposing` is the state with the external
  entry.
- Deployment is its own type per target, because the provider holds it as one, targets differ per repository so a
  release's machine would otherwise differ too, and a retry is naturally a new instance rather than a loop.
- Continuous delivery is derived on the order, because deployment is a fact about a release, and an order that had
  a deployment state would have to change every time a release did.

## Consequences

- The figure is jig's illustration of these machines now and the fixture presenting's renderer must match once jig
  draws lifecycles itself.
- Mediating, in jig-004, maps the provider's acts onto these transitions and nothing else.
- Recording, in jig-005, has to give an issue a version, since the provider keeps none.
- The labels the standard policy projects onto the provider follow these names; the label a repository uses today
  for an approved order maps to `approve(verdicts)` until it is renamed.

## Open questions

- The names `schedulers`, `cancel(reason)`, `closed`, `bind` and `unbind` are the current spellings and may still
  change.
- Whether the organization's requirement on the policy in force is an approver of the release or of the deployment
  into production.
- Whether a Release needs a state between `released` and its deployments.

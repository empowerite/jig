# Engine: ticking, batching, landing

Status: draft

## Decision

The engine is one function, `next(policy, view) → actions`, and it is generic over the lifecycles the policy declares:
it knows the kinds of [rfc-001-types.md](rfc-001-types.md), ground, derived and excited states, silent and acted
transitions, and the capabilities a port offers, and it knows no state by name. It takes the policy and the view and
returns the actions that are due. It reads no provider and writes nothing. A tick calls it once and executes what it
returns through the ports of [rfc-003-ports.md](rfc-003-ports.md).

### The tick

1. Read: each port's changes since its cursor, or a resync when the cursor is lost or the schedule says so. A
   read that fails leaves its part of the view unknown.
2. Evaluate: `next` over the view. For every instance of every type, compute its derived states from the facts. Take
   every enabled silent transition. For every acted transition whose actor is this jig, request through the gate port
   each verdict its guard is missing, and queue the transition when every gate in its guard is green and no hold is
   set. Nothing is queued for an instance this jig does not own, unless policy hands it the board.
3. Act: each queued action through its port, in order, each carrying the precondition it was computed under.
   A port that finds the precondition false refuses the action, and the refusal is a fact for the next tick.
4. Record: the cursors advanced, the metrics of every call, and the tick's own summary.

A tick is idempotent: run twice over the same world, the second run acts on nothing, because every action's
precondition is what the first run changed. A tick over unknowns acts on nothing it cannot see.

A tick's scope is one work item and its changes, which is what a desk or a session runs, or the whole board,
which is what a jigbot runs.

### Two rules

- The guard reads facts and never runs anything. A verdict the guard is missing is a state the tick owns by requesting
  it, and the transition waits. The request is an action like any other and is idempotent: a verdict already requested
  for a gate and a digest is not requested again.
- The policy that judges a change is the base's, never the change's own. A change that edits the policy is evaluated
  under the policy in force on the default branch, plus policy check over the file it proposes, and the policy it
  proposes is in force from its integration onward.

### The batch

A batch is how admissible changes land together on one gate run.

- Admission: a change is a candidate when it is admissible and this jig owns it or holds the board.
- Partition: candidates group by the partition key policy names; a batch holds one group.
- Cap: a batch holds at most the smallest cap among its members, and a `solo` change caps at one.
- Order: priority first, then relations, a dependency before what depends on it, then provider number.
- Build: the scm port makes a speculative tree, the default branch plus each member's squashed change in order,
  on a ref outside `refs/heads`, and the gate port runs the gates over it once.
- Verdict: green lands the batch; red bisects it.

### Landing

The green prefix of a batch lands as soon as it is proven, member by member in order, each through the integrate
port's path with a head-match guard, so a member whose branch moved is dropped rather than landed unverified. The
port reports what landed, a new commit over the tested tree or the tested commit itself, and the engine chains the
next member from that. A landing that the provider refuses stops the batch; what landed stays landed, and the rest
is rebuilt on the new default branch at the next tick.

### Bisection

A red batch of k members is split at the first half: the first half is rebuilt and run, and a green half lands
while the other half is halved again, until a red batch of one names the culprit. The culprit returns to proposed
with the batch's record of why; every other member returns to admissible and re-batches. Nothing inside a batch is
ever repaired in place, and a gate outage is not a red batch; it is waited on.

### The lease

When several jigs hold the board, one leads the batch. Leadership is a lease: a compare-and-swap on a ref outside
`refs/heads`, carrying the leader's actor, a heartbeat and an epoch, through the scm port. A jig whose swap
succeeds leads; a jig that reads a fresh heartbeat naming another follows and builds nothing; a stale heartbeat is
adopted at the next epoch. The lease is an efficiency, so that two jigs do not build the same batch twice.
Correctness never rests on it: the head-match guard on each member and the compare-and-swap on the default branch
are what keep two landings from composing an untested tree.

### What the engine may write

Exhaustively: an instance's assignee, state and jig-owned annotations, through its location port; a change's draft
flag and state, through the change port; the speculative ref and the lease ref, through the scm port; a member's
branch at the landing instant, to its own tested commit, and the default branch through the integrate port's own
merge; a verdict request, through the gate port; an attestation, into the slot the provider offers; and the cursors
and metrics, in jig's own view. It rebases no member, edits no person's text, and starts no actor.

## Why

- A pure function, because it is the only shape that is testable with no network and the only one two jigs can
  run and agree on.
- Idempotent ticks, because a tick will be re-run after a crash, a timeout or a doubt, and a tick that could act
  twice would need a memory the design refuses to keep.
- Landing by the port's own path, because the default branch's rules attach a review and a signature at the merge
  event and nowhere else, and a raw push would land a change the rules never saw.
- The lease as an efficiency only, because a lock a network can lose is a lock a design cannot trust; the guard on
  the ref is what a provider itself enforces.
- Bisection by halves, because a red batch of k should cost log k rebuilds and no member should wait on the
  culprit's isolation longer than it must.
- Generic over the lifecycle, because an engine that knew a state by name would have to change with every
  organization's lifecycle, and the kinds are enough to know at every state whether to wait, to compute, or to act.
- The base's policy, because a change that could be judged by the policy it proposes could admit itself, and the one
  policy every change is judged by is the one already landed.

## Consequences

- The engine's test suite runs against the fakes of [rfc-003-ports.md](rfc-003-ports.md) and covers every kind of
  state and transition over a declared lifecycle, and every branch of the batch: a red batch of k isolates its culprit
  in at most ⌈log₂ k⌉ rebuilds.
- A jigbot, [rfc-009-jigbot.md](rfc-009-jigbot.md), is this engine run board-wide on a schedule and on events, holding
  the lease.
- The operator surface, [rfc-006-operator-surface.md](rfc-006-operator-surface.md), shows a tick's record and the
  batch's state.

## Open questions

- Where a tick's record lives so that desks can read a jigbot's: a ref outside `refs/heads`, or the provider's own
  comment on the change, or both.
- Whether an integrate path that is the provider's own queue, a merge train, replaces the batch entirely or feeds
  it; the answer is per port and belongs to its section of `rfc-003`.

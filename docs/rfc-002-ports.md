# Ports: contracts, proofs, metrics

Status: draft

## Decision

A port is the typed interface between the model in [rfc-001-world-model.md](rfc-001-world-model.md) and one provider. It
translates the provider's objects into the model's types and the model's actions into the provider's calls, and it
is the only code in jig that speaks to a provider. The engine, the policy and the operator surface see ports and
never a provider.

### The kinds

A port is of one kind per model type it binds, and one provider may be several ports.

- A work port binds work items to a tracker: GitHub Issues, Azure DevOps, Linear.
- A change port binds changes to their host: GitHub pull requests, GitLab merge requests.
- A gate port binds verdicts to whatever produces them: a CI system, a check run, a command the repository declares
  such as `just test`, run on a desk.
- An integrate port lands a change on the default branch by one of the paths its provider offers: a merge through
  the provider's own API, a merge queue or train, or a batch built by jig.
- An scm port binds branches, refs and trees to git: the one provider every host shares, spoken to directly.
- A harness port delivers a brief and the rules for a path to an agent harness: a Claude Code hook, a Cursor rule.

### The contract

Every port keeps one contract, in five parts.

- The three operations the model needs, per type it binds: read what changed since a cursor; resync, a full read;
  and act, one call per action in the lifecycle's tables. An action that the provider refuses is reported as
  refused, with the provider's reason, never retried in silence.
- Capabilities: the canonical paths this port offers for each lifecycle step, with their sub-states, so policy can
  choose among them and the interface can draw them.
- Constraints: the facts the engine must respect before it acts, read from the provider and not assumed. For an
  integrate port: whether fast-forward is allowed, whether signatures are required, whether a review must attach
  at the merge event, which merge methods the branch's rules accept. For a work port: page maxima and rate limits.
- Slots: where in this provider each of jig's own facts lives, the identity and the correspondence between
  bindings, and where each attribute lives, `due` above all, since a label cannot hold a date.
- Metrics: every call counted and timed, labeled by port, operation and outcome, with the provider's rate-limit
  budget read and reported, so the cost of a tick is a number and not a feeling.

### The cursor

A port defines its own cursor for changes-since, in the provider's terms: an updated-since timestamp, an event
sequence, a delivery id. The cursor is jig's fact, kept per port, and losing it costs one resync. A resync is
never a substitute for the cursor read; it is the safety net, run on a schedule and on demand.

### Proofs

A port is trusted by three tiers, and the third is the contract.

- A fake: an in-memory port of the same kind, deterministic, for the engine's tests. The engine's whole suite runs
  against fakes and no network.
- Recorded traffic: real requests and responses captured once from the live provider and replayed, so a port's own
  tests are fast and offline. A recording is evidence of what the provider did on the day it was made.
- A live conformance suite: one per port, run against a scratch repository on the real provider, on a schedule and
  on every change to that port. It exercises every operation, every capability and every constraint the port
  claims, and it is what makes a claim about a provider a measurement. A port that does not pass it is not a port.

### Honesty

A port never answers an unanswerable read with an empty result. A provider that could not be reached, a rate limit
met, a query refused: each is a failure the port reports, and the engine treats a failed read as unknown, never as
nothing. A tick over unknowns acts on nothing it cannot see.

### The first ports

GitHub is the first work, change, gate and integrate port, and git the first scm port. Every later port, GitLab,
Azure DevOps, Linear, is written to the contract above and proven by its own suite before it binds anything.

## Why

- Ports are the only code that speaks to a provider because the state belongs to the systems that hold it: a
  second path to a provider is a second writer, and a second writer is a second truth.
- The engine's tests run against fakes because orchestration is a function call, and a function is tested by
  calling it, not by standing up GitHub.
- Constraints are read and not assumed because the facts that shape a landing were measured, not derived: which
  merge methods a ruleset accepts, whether a signature is required, what a retarget does to a pull request. A port
  that assumed any of them would be right until the provider changed.
- The live suite is the contract because a recording ages and a fake believes whatever it was told. Only the
  provider can say what the provider does today, and the suite is the question asked on a schedule.
- Every call is metered because a tick has a price in a provider's budget, and a design that cannot see the price
  cannot be cost-aware.
- An unanswerable read is a failure because a green over nothing is the one report worse than a red: it says all
  is well about a world it did not look at.

## Consequences

- The engine, [rfc-004-engine.md](rfc-004-engine.md), reaches every provider through these operations and no other,
  and its lease lives in the scm port's compare-and-swap on a ref.
- Policy, [rfc-003-policy.md](rfc-003-policy.md), chooses among the capabilities a port declares and cannot name a
  path a port does not offer.
- The operator surface, [rfc-005-operator-surface.md](rfc-005-operator-surface.md), shows the metrics every port
  reports.
- A scratch repository per provider, for the live suite, is provisioned outside this repository.

## Open questions

- Which slot each provider uses for the identity and for `due`: a body line, a milestone, a project field, a tag.
  Settled per port, in that port's own section of this spec as it is written.
- Whether a gate port's local form, a command on a desk, reports through the same verdict type as a hosted one, or
  a narrower one without artifacts.
- How the rate-limit budget is spent when several jigs share one provider account.

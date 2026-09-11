# Ports: contracts, proofs, metrics

Status: draft

## Decision

A port is the typed interface between the model in [jig-001-types.md](jig-001-types.md) and one provider. It
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
- An scm port binds branches, refs and trees to git: the one provider every host shares, spoken to directly. It is
  also the location port for a file-backed type: an instance of such a type is whatever it reads at a path in a tree,
  at that blob's digest.
- A harness port delivers the brief to an agent harness: a Claude Code hook, a Cursor rule.

### The contract

Every port keeps one contract, in five parts.

- The operations the model needs, per type it binds: read what changed since a cursor; resync, a full read; act, one
  call per action in the lifecycle's tables; and, for a gate port, request a verdict for one gate over one subject at
  a digest. On a desk the port runs the command now. On the provider it triggers the check, or waits for the one a
  push already raised. For a gate that is an extension, it invokes the extension in the tick. The engine's guard reads
  a verdict and never runs a gate; a missing verdict is requested through this operation and the transition waits. The
  verdict a gate port produces is the record of [jig-003-gates.md](jig-003-gates.md), one shape for a command, a check
  and an extension. An action that the provider refuses is reported as refused, with the provider's reason, never
  retried in silence.

```text
// a port's contract: one method per operation the model needs, and nothing else the model may call
Port:
	ReadSince(cursor) -> (events, newCursor)  // changes since the last read
	Resync()          -> (view, newCursor)    // a full read, on schedule or on demand
	Act(action)       -> (result)             // one call per action the lifecycle's tables name

GatePort extends Port:
	RequestVerdict(gate, subject, digest) -> (verdict)  // one gate, one subject, one digest; the guard only reads it
```

- Capabilities: the canonical paths this port offers for each lifecycle step, with their sub-states, so policy can
  choose among them and the interface can draw them. A change port also declares which tree its provider tests for a
  change, the merge of head onto base on GitHub. The guard for admissible reads verdicts keyed by that tree; the guard
  for integrating reads verdicts keyed by the batch's speculative tree; a file-backed instance's verdicts are keyed by
  its blob. A verdict on any other tree is a fact about that tree and satisfies no guard.

```cue
// the capabilities the GitHub change port declares, one canonical path per lifecycle step
capabilities: change: github: {
	propose:    {paths: ["draft", "ready-for-review"]}  // opened as a draft pull request, or opened ready
	admissible: {tree: "merge"}                         // GitHub tests head merged onto base; verdicts key on it
	integrate:  {paths: ["merge", "squash", "rebase"]}  // methods the branch ruleset may accept
}
```

- Constraints: the facts the engine must respect before it acts, read from the provider and not assumed. For an
  integrate port: whether fast-forward is allowed, whether signatures are required, whether a review must attach
  at the merge event, which merge methods the branch's rules accept. For a work port: page maxima and rate limits.
- Slots: where in this provider each of jig's own facts lives, the identity and the correspondence between bindings,
  where each attribute lives, `due` above all, since a label cannot hold a date, and where an attestation is stored:
  an attestation store keyed by digest where the provider has one, a ref or a note where it does not, a comment last.
- Metrics: every call counted and timed, labeled by port, operation and outcome, with the provider's rate-limit
  budget read and reported, so the cost of a tick is a number and not a feeling.

```json
// one call to the GitHub change port, as the metrics slot reports it
{
  "port":        "github-change",
  "operation":   "act:propose",
  "outcome":     "ok",
  "duration_ms": 340,
  "rate_limit":  {"remaining": 4821, "limit": 5000, "reset": "2026-09-11T07:00:00Z"}
}
```

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

```text
// one case from the GitHub change port's live conformance suite, run against a scratch repository
test "propose opens a draft pull request":
	act:    Act(propose(change)) on a fresh branch
	assert: change.state == "proposed"
	assert: provider.pull_request.draft == true
	assert: capabilities.change.github.propose.paths contains "draft"
```

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

- The engine, [jig-008-engine.md](jig-008-engine.md), reaches every provider through these operations and no other,
  and its lease lives in the scm port's compare-and-swap on a ref.
- Policy, [jig-005-policies.md](jig-005-policies.md), chooses among the capabilities a port declares and cannot name a
  path a port does not offer.
- The operator surface, [jig-011-operator-surface.md](jig-011-operator-surface.md), shows the metrics every port
  reports.
- A scratch repository per provider, for the live suite, is provisioned outside this repository.

## Open questions

- Which slot each provider uses for the identity and for `due`: a body line, a milestone, a project field, a tag.
  Settled per port, in that port's own section of this spec as it is written.
- How the rate-limit budget is spent when several jigs share one provider account.

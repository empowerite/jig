# jigbot: ticking in the cloud

Status: draft

## Decision

jigbot is the engine of [jig-005-engine.md](jig-005-engine.md) run board-wide, hosted by the repository's own CI
through the gate port's provider, as its own actor. It is optional the way an automated dependency updater is
optional: a repository adds one workflow file and has a jigbot; a repository without one has people and sessions
running the same verbs by hand.

### The actor

jigbot runs as a bot account of its own, a GitHub App on GitHub, never as a person. That is what makes an
`accepted` label set by a person distinguishable from one set by a machine, what lets the ownership rule of
[jig-001-types.md](jig-001-types.md) apply to it like any other actor, and what gives its calls their own
rate-limit budget.

### The tick

The workflow runs `jig tick` on the events that change the board, an issue or pull request opened, edited,
labeled or closed, a check completed, a push to a branch with an open pull request, and on a schedule as the
safety net. Each run is one tick: read since the cursors, evaluate, act, record. Two runs never build the same
batch twice because jigbot holds the lease.

### The view

jigbot publishes the view it computed on a hidden ref, `refs/jig/view`, one commit per tick over the previous, so a
desk reads the board by fetching one ref instead of re-reading the provider, and a person can `git show` what
jigbot saw. The ref is outside `refs/heads`, so it triggers no workflow and is fetched by nothing by default.

### What it needs

The App's token, with the permissions the ports need and no more; the pinned `jig` from `mise`; and the workflow
file. No other secret. `jig doctor`, run in the workflow, reports what the token cannot do.

### What it does not do

It starts no actor. It publishes needs through `jig context --needs` and moves state through the verbs; a person or
a dispatcher outside jig decides who works. It rebases nobody's branch, edits nobody's text, and never merges
except as the landing step of a batch that policy gave it.

## Why

- One poller per repository, because the rate-limit budget is spent once and no desk pays for the board twice.
- Its own actor, because a machine acting as a person makes every label and assignment a lie about who decided.
- Events with a schedule behind them, because events are cheap and lost, and a schedule is dear and reliable.
- The view on a ref, because git is the one substrate every provider shares, and a ref is the only shared, durable
  place that needs no service.

## Consequences

- The App and its permissions are provisioned outside this repository, beside the scratch repositories of the
  live suites.
- The batch of `jig-005` lands from the leader's tick, whoever holds the lease; a running jigbot is the usual leader,
  and a desk's `jig land` is a person's own merge.
- Under a strict ruleset, a change must be current with the default branch before it merges, and jigbot never
  rebases a member; the batch's landing path satisfies strictness by construction, and a change outside a batch is
  its owner's to bring current.

## Open questions

- Whether the view ref is one commit per tick over the previous, or replaced each tick, and how far back a desk
  needs to read.
- Whether jigbot may bring current the branches its own actor owns, and only those, under strictness.

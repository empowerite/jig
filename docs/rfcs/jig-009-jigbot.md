# jigbot: ticking in the cloud

Status: draft

## Decision

jigbot is the engine of [jig-005-engine.md](jig-005-engine.md) run board-wide, hosted by the repository's own CI
through the gate port's provider, as its own actor. It is optional the way an automated dependency updater is
optional: a repository adds one workflow file and has a jigbot; a repository without one has people and sessions
running the same verbs by hand.

### The actor

jigbot runs as a bot account of its own, a GitHub App on GitHub, never as a person, and so does a session on a desk.
That is what makes an `accepted` label set by a person distinguishable from one set by a machine, what lets the
ownership rule of [jig-001-types.md](jig-001-types.md) apply to either like any other actor, and what gives their
calls their own rate-limit budget.

A session acts as a GitHub App on every desk and never as the person's login, and a session started through the
harness port with no App to act as is refused before it posts anything. Two ways put an App's key on a desk, both
GitHub-native, and jig requires neither in particular.

- A per-person App, the default. The person registers it, an owner of the organization approves its installation once,
  and its key exists only on that person's desks. Its posts appear under the App's bot login, and an App's owner is a
  fact GitHub publishes, so the author of a post is that person's agent with no line of configuration. A stolen desk
  exposes one App, which the owner uninstalls.
- One organization App and a broker, for a large organization. The organization holds the key where no desk is, a
  service or a workflow, and the broker mints tokens narrowed to one repository for people it authenticates through
  GitHub. Every session's posts appear under the organization's bot, and whose session it was is the broker's record.
  jig ships a reference broker the way [jig-007-extensions.md](jig-007-extensions.md) ships a reference dispatcher.

A person typing a verb at their own keyboard is still the person: the verb is theirs, and the provider records the
fact under their login. Commits stay the person's, authored and signed on the desk with the session named in a
trailer; the App pushes, opens the pull request and comments.

### The tick

The workflow runs `jig tick` on the events that change the board, an issue or pull request opened, edited,
labeled or closed, a check completed, a push to a branch with an open pull request, and on a schedule as the
safety net. Each run is one tick: read since the cursors, evaluate, act, record. Two runs never build the same
batch twice because jigbot holds the lease.

### The view

jigbot publishes the view it computed on a hidden ref, `refs/jig/view`, one commit per tick over the previous, so a
desk reads the board by fetching one ref instead of re-reading the provider, and a person can `git show` what
jigbot saw. The ref is outside `refs/heads`, so it triggers no workflow and is fetched by nothing by default.

```text
$ git show refs/jig/view
commit 9f1c3a7e2b8d4f605a1e9c3b7d2f8a4e6c1b9d3a
Author: empowerite-jig[bot] <empowerite-jig[bot]@users.noreply.github.com>
Date:   Fri Sep 11 06:13:02 2026 +0000

    tick 214: change #98 admissible -> integrating

diff --git a/change-98.json b/change-98.json
index 2f6a1c9..7b3d4e0 100644
--- a/change-98.json
+++ b/change-98.json
@@ -1 +1 @@
-{"identity": "github.com/empowerite/jig#98", "digest": "tree:9a3f2c1e…", "state": "admissible"}
+{"identity": "github.com/empowerite/jig#98", "digest": "tree:9a3f2c1e…", "state": "integrating"}
```

### What it needs

The App's token, with the permissions the ports need and no more; the pinned `jig` from `mise`; and the workflow
file. No other secret. `jig doctor`, run in the workflow, reports what the token cannot do.

One App per organization, registered by the organization and installed on all of its repositories or a chosen set, and
never one App jig owns: an App's key mints every token, and a jig-owned App would make jig a service holding every
organization's credentials. A personal account registers its own the same way under its own settings.

`jig app create` registers it through GitHub's manifest flow. jig computes the manifest from the permissions the bound
ports need, with no webhook and no user authorization, opens the form filled in, receives the App's ID and key on a
listener on localhost when the person clicks create, stores the key, and opens the install page for the second click.
Then it verifies the installation and reports.

A repository learns of the App through two channels, and jig joins them. The App's slug and ID are public facts,
declared in the organization's link of the chain as the binding of the jigbot actor, so every repository that pulls
the link knows which App is jig's actor there. The key is an organization Actions secret, `JIG_APP_PRIVATE_KEY`, and
the ID an organization variable, `JIG_APP_ID`, shared with the repositories and read by the reusable workflow of
[jig-010-release.md](jig-010-release.md) under those names. A repository with an App of its own sets the same two at
its own level, and its own win. A personal account, having no organization secrets, sets them per repository.

```yaml
# .github/workflows/jigbot.yml: what a repository adds; the two names are the organization's secret and variable
name: jigbot
on:
  issues: {types: [opened, edited, labeled, closed]}
  pull_request: {types: [opened, edited, labeled, closed]}
  check_run: {types: [completed]}
  push:
  schedule: [{cron: "*/15 * * * *"}]
jobs:
  tick:
    uses: empowerite/jig/.github/workflows/jigbot.yml@v1
    secrets:
      JIG_APP_PRIVATE_KEY: ${{ secrets.JIG_APP_PRIVATE_KEY }}
    with:
      JIG_APP_ID: ${{ vars.JIG_APP_ID }}
```

`jig doctor` reports the join. On a runner it says whether the workflow found the two and what the token cannot do. On
a desk it says which App the session acts as, from the key the keychain holds under the App's slug, and refuses a
session that has none.

```text
$ jig doctor
JIG_APP_ID:          found (512034, empowerite-jig)
JIG_APP_PRIVATE_KEY: found
token:               missing the scope the gate port needs to attach a verdict to a check run
```

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
- A session as an App on every desk, because a session acting as a person is not distinguishable from the person, and
  telling who decided is what the record is for.
- Per-person Apps as the default, because a key on a laptop should open one App and not an organization, and because
  an App's owner is a fact GitHub publishes, so attribution costs no configuration.
- The manifest flow, because a form of a dozen fields is filled in wrong once per organization, and a binary can hold
  the listener the flow needs where a script cannot.

## Consequences

- The App is registered in the organization's settings by `jig app create`, and its key and ID are provisioned as the
  organization's secret and variable. Nothing about it is committed, and the install page says what it is, what it may
  do, and how a desk or a runner authenticates as it.
- The actor rule of [jig-001-types.md](jig-001-types.md) gains a predicate over the owner of the App that posted, so
  that a policy allows an agent of a maintainer to propose and forbids it to accept without naming anyone. That clause
  is jig-001's, made in its own amendment.
- The batch of `jig-005` lands from the leader's tick, whoever holds the lease; a running jigbot is the usual leader,
  and a desk's `jig land` is a person's own merge.
- Under a strict ruleset, a change must be current with the default branch before it merges, and jigbot never
  rebases a member; the batch's landing path satisfies strictness by construction, and a change outside a batch is
  its owner's to bring current.

## Open questions

- Whether the view ref is one commit per tick over the previous, or replaced each tick, and how far back a desk
  needs to read.
- Whether jigbot may bring current the branches its own actor owns, and only those, under strictness.
- Whether a session may author commits as its App through GitHub's commit API, signed by GitHub and attributed to the
  bot, which would retire the trailer, or commits stay the person's.
- What the reference broker is, a workflow or a service, and where it runs.

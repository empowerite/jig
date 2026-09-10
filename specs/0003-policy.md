# Policy: what a repository declares

Status: draft

## Decision

A repository declares its SDLC in one committed file at its root, `jig.toml`. The file is data: it names choices
among what the model in [0001-world-model.md](0001-world-model.md) and the ports in [0002-ports.md](0002-ports.md) already
offer, and it can name nothing else. jig reads it at every tick, validates it with `jig policy check`, and shows
what a change to it would do to work in flight with `jig policy plan`. A change to the file is a change like any
other and goes through the loop the file describes.

### What the file names

- Ports and roles: which provider plays which role for the work item, `origin`, `work`, `report`, and which
  provider hosts changes, gates and integration. One provider may play every role.
- Paths: for each lifecycle step, which of the canonical paths the port offers realizes it: a draft pull request
  or a `WIP:` title, a merge through the provider's API, its merge queue, or jig's batch.
- Gates: for each transition that has one, the named verdict sources that must report green: a check by name, a
  command the repository declares such as `just test`, a review, an approval count.
- Actors: for each transition, who may take it: a person, a session acting as a person, a bot, the batch. The
  ownership rule, that a running jig acts only on what its actor is assigned, is jig's and not the file's.
- Attributes: the provider-side name of each attribute the model reads: which label is `accepted`, which is
  `parked`, which field or milestone is `due`, which label family is `priority`.
- Batch formation: the partition key, the default per-member cap and the label that means `solo`, the ordering,
  and whether a red batch is bisected or simply rebuilt without its newest member.
- Naming: the shape of a landed commit's subject, and any branch-name habit, stated as a habit.
- Realized: which post-integration verdict counts, and whether a work item's `resolved` waits for it or for
  `integrated` alone.
- The lifecycle version the file was written against.

### Validation

`jig policy check` refuses a file that names a port jig lacks, a path the port does not offer, a gate no port can
report, an actor the lifecycle does not know, or an attribute slot the port cannot read. It runs as a policy step
on every pull request that touches the file, and on a desk before a commit.

### The plan

`jig policy plan` takes the file as committed and the file as changed, evaluates both against the current view,
and prints every work item and change whose state, admissibility or ownership would differ: what becomes
admissible, what stops being, what a person now must do that a bot did before. A change that empties a batch or
strands a change in flight is named as such. The plan is read before the change is merged, and it is the whole of
what "changes to the SDLC are a managed process" means in practice.

## Why

- One file, because two clones at one commit must run the same process, and a process split across settings
  pages and a file runs differently on each desk.
- Data and not code, because a policy that can compute is a workflow language, and the charter rules that out.
  What varies between repositories is which gates, which actors, which paths; the shape does not.
- Choices among what ports offer, because a policy that could name a path no port implements would be a promise
  the engine cannot keep, and the check that refuses it is cheaper than the tick that discovers it.
- A plan before a change, because a policy change is the one change whose blast radius is every item in flight,
  and reading a diff of a file says nothing about which of them it touches.

## Consequences

- The engine, [0004-engine.md][0004], evaluates every transition's gate and actor from this file and nothing else.
- The operator surface, [0005-operator-surface.md][0005], carries `jig policy check` and `jig policy plan`, and
  `jig init` writes the first file from what the ports find.
- An extension, [0006-extensions.md][0006], is declared here, never discovered.
- The check that validates the file joins the policy workflow as a step.

## Open questions

- TOML is the format because `mise` already puts one TOML file at the root and Go reads it well. Whether a policy
  ever needs more than TOML expresses is a question to answer with a real repository's file, not in advance.
- Whether `realized` gates `resolved` by default. The default proposed here is yes, since merged is not done.

[0004]: https://github.com/empowerite/jig/issues/9
[0005]: https://github.com/empowerite/jig/issues/10
[0006]: https://github.com/empowerite/jig/issues/11

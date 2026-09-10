# Specs

The decision record. Each part of jig gets one spec here, written before its code and held as what the code is checked
against. A spec says what was decided and why. How to use the result is `docs/`'s job, and a user never needs to open
this directory; an extender needs both.

## Discipline

- A spec is a file named `NNNN-<slug>.md`. `NNNN` is four digits in the order the designs were made, and a number is
  never reused, so a superseded spec keeps its place in the record.
- The first line after the title is the status: `Status: draft`, `Status: accepted`, or
  `Status: superseded by NNNN`. A person accepts a spec the way a person accepts an issue, by reading it and saying
  so; the status changes in a pull request a maintainer merges.
- The sections come in this order, so the decision is read first and the argument only by someone who questions it:
  `## Decision`, what is decided, in the imperative; `## Why`, the argument; `## Consequences`, what follows for
  other specs, for the code, and for the operator. Open questions are named under their own heading, never buried.
- A spec and the code do not disagree. The change that would make them disagree corrects the spec, or marks it
  superseded and writes the successor, in the same pull request. A spec never rots silently.
- A link to a spec that has not landed names the spec's issue, and the pull request that lands the spec rewrites
  every such link to the file. A link to a file that is not there is a red check.
- The writing rules in [CLAUDE.md](../CLAUDE.md) apply: plain sentences, lists where the content is a list, a blank
  line after every block.

## Index

One line per spec, in number order: the file, its subject, its status. jig will generate this index once it
can; until then it is kept by hand.

- [0001-world-model.md](0001-world-model.md): world model and lifecycle (draft)
- [0002-ports.md](0002-ports.md): port contracts, proofs, metrics (draft)
- [0003-policy.md](0003-policy.md): what a repository declares (draft)
- [0004-engine.md](0004-engine.md): ticking, batching, landing (draft)
- [0005-operator-surface.md](0005-operator-surface.md): CLI, API, GUI (draft)

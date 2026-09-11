# RFCs

The record behind every accepted decision, and the index of the RFCs themselves.

## The record

- An RFC is a file in this directory named `jig-NNN-<slug>.md`. `NNN` is three digits, 000 is the charter, and a new
  RFC takes the next free number. Once an RFC has been accepted its number is never reused, so a superseded RFC keeps
  its place in the record.
- The first line after the title is the status: `Status: draft`, `Status: accepted`, or
  `Status: superseded by jig-NNN`. A person accepts an RFC the way a person accepts an issue, by reading it and
  saying so; the status changes in a pull request a maintainer merges.
- The sections come in this order, so the decision is read first and the argument only by someone who questions it:
  `## Decision`, what is decided, stated declaratively with the thing decided as its subject; `## Why`, the argument;
  `## Consequences`, what follows for other RFCs, for the code, and for the operator. Open questions are named under
  their own heading, never buried.
- An accepted RFC and the code do not disagree. The change that would make them disagree corrects the RFC, or
  marks it superseded and writes the successor, in the same pull request. An RFC never rots silently.
- A link to an RFC that has not landed names the RFC's issue, and the pull request that lands the RFC rewrites
  every such link to the file. A link to a file that is not there is a red check.
- An example in an RFC is fenced with its language and sits beside the prose it illustrates. It shows one thing that
  satisfies the prose and decides nothing on its own; where the two disagree the prose is right and the example is a
  bug. Once jig can check it, an example is a fixture the code is checked against.
- The `## Decision` of an RFC uses only what an RFC with a lower number defines, and names no higher number; a
  higher number is named under `## Consequences` or `## Open questions`. Reading 000 through NNN in order therefore
  defines every word NNN uses. The charter is exempt, since naming the parts is its job, and so is an example, since
  it decides nothing.

The writing rules in [CLAUDE.md](../../CLAUDE.md) apply to pages and RFCs alike: plain sentences, lists where the
content is a list, a blank line after every block.

## Index

One line per RFC, in number order with its status. jig will generate this index once it can; until then it is kept
by hand.

- [jig-000-charter.md](jig-000-charter.md): what jig is and is not (draft)
- [jig-001-types.md](jig-001-types.md): the unit of policy is a declared entity type; the kinds, the chain,
  the attested verdict (draft)
- jig-002, values: an instance of a type, at a version ([#108](https://github.com/empowerite/jig/issues/108))
- jig-003, gates: one judgment over one value at one version
  ([#108](https://github.com/empowerite/jig/issues/108))
- jig-004, lifecycles: states and transitions on a type ([#108](https://github.com/empowerite/jig/issues/108))
- jig-005, policies: types with gates attached, composed up the chain
  ([#108](https://github.com/empowerite/jig/issues/108))
- [jig-006-ports.md](jig-006-ports.md): port contracts, proofs, metrics (draft)
- [jig-007-composition.md](jig-007-composition.md): several providers, moving between them (draft)
- [jig-008-engine.md](jig-008-engine.md): ticking, batching, landing (draft)
- [jig-009-language.md](jig-009-language.md): what a policy is written in (draft)
- [jig-010-extensions.md](jig-010-extensions.md): extension points, what they expose (draft)
- [jig-011-operator-surface.md](jig-011-operator-surface.md): CLI, API, GUI (draft)
- [jig-012-jig-context.md](jig-012-jig-context.md): state to brief (draft)
- [jig-013-release.md](jig-013-release.md): jig's own lifecycle, releases (draft)
- [jig-014-jigbot.md](jig-014-jigbot.md): ticking in the cloud (draft)

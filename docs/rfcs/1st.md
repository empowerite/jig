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

The writing rules in [CLAUDE.md](../../CLAUDE.md) apply to pages and RFCs alike: plain sentences, lists where the
content is a list, a blank line after every block.

## Index

One line per RFC, in number order with its status. jig will generate this index once it can; until then it is kept
by hand.

- [jig-000-charter.md](jig-000-charter.md): what jig is and is not (draft)
- [jig-001-types.md](jig-001-types.md): the unit of policy is a declared entity type; the kinds, the chain,
  the attested verdict (draft)
- [jig-002-language.md](jig-002-language.md): what a policy is written in (draft)
- [jig-003-ports.md](jig-003-ports.md): port contracts, proofs, metrics (draft)
- [jig-004-composition.md](jig-004-composition.md): several providers, moving between them (draft)
- [jig-005-engine.md](jig-005-engine.md): ticking, batching, landing (draft)
- [jig-006-operator-surface.md](jig-006-operator-surface.md): CLI, API, GUI (draft)
- [jig-007-extensions.md](jig-007-extensions.md): extension points, what they expose (draft)
- [jig-008-jig-context.md](jig-008-jig-context.md): state to brief (draft)
- [jig-009-jigbot.md](jig-009-jigbot.md): ticking in the cloud (draft)
- [jig-010-release.md](jig-010-release.md): jig's own lifecycle, releases (draft)

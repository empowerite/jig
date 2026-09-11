# Docs

How to install, use and extend jig, in the present tense, and the record of the decisions behind it. A page describes
what jig is and does today. An RFC says what was decided and why, and once accepted it is the spec the code is checked
against. A user reads the pages and skips the RFCs; an extender reads both. Setting up a desk or a runner to work in
this repository is [README.md](../README.md).

## Pages

- A page describes the current state. It carries no history, no "previously", no account of how a thing came to
  be; git holds that.
- A page is written for a user or an extender, never for a designer. The reason a thing is the way it is belongs
  in its RFC, and a page that needs a reason points at the RFC with `see:` rather than repeating the argument.
- A page assumes a reader who has never seen this repository and has read no RFC.
- A page is one of three kinds, install, use, or extend, and says which in its first line.
- A page and the code do not disagree. The pull request that changes a behavior changes the page that describes
  it.

## The record

- An RFC is a file in `rfcs/` named `jig-NNN-<slug>.md`. `NNN` is three digits, 000 is the charter, and a new RFC
  takes the next free number. Once an RFC has been accepted its number is never reused, so a superseded RFC keeps its
  place in the record.
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

The writing rules in [CLAUDE.md](../CLAUDE.md) apply to pages and RFCs alike: plain sentences, lists where the
content is a list, a blank line after every block.

## Index

One line per file: the pages, then the RFCs in number order with their status. jig will generate this index once
it can; until then it is kept by hand.

- [rfcs/jig-000-charter.md](rfcs/jig-000-charter.md): what jig is and is not (draft)
- [rfcs/jig-001-types.md](rfcs/jig-001-types.md): the unit of policy is a declared entity type; the kinds, the chain,
  the attested verdict (draft)
- [rfcs/jig-002-language.md](rfcs/jig-002-language.md): what a policy is written in (draft)
- [rfcs/jig-003-ports.md](rfcs/jig-003-ports.md): port contracts, proofs, metrics (draft)
- [rfcs/jig-004-composition.md](rfcs/jig-004-composition.md): several providers, moving between them (draft)
- [rfcs/jig-005-engine.md](rfcs/jig-005-engine.md): ticking, batching, landing (draft)
- [rfcs/jig-006-operator-surface.md](rfcs/jig-006-operator-surface.md): CLI, API, GUI (draft)
- [rfcs/jig-007-extensions.md](rfcs/jig-007-extensions.md): extension points, what they expose (draft)
- [rfcs/jig-008-jig-context.md](rfcs/jig-008-jig-context.md): state to brief (draft)
- [rfcs/jig-009-jigbot.md](rfcs/jig-009-jigbot.md): ticking in the cloud (draft)
- [rfcs/jig-010-release.md](rfcs/jig-010-release.md): jig's own lifecycle, releases (draft)

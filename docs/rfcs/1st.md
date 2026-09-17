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

The series restarted at 000 on 2026-09-17, by [#123](https://github.com/empowerite/jig/issues/123); the RFCs it
replaces are in [superseded/1st.md](superseded/1st.md). Until an RFC below has landed, its line names its issue.

- [jig-000-charter.md](jig-000-charter.md): what jig is and is not (draft)
- [jig-001-desk.md](jig-001-desk.md): where jig runs, and at which version (draft)
- [jig-002-lifecycles.md](jig-002-lifecycles.md): state kinds, components, and the two gates every policy repeats (draft)
- [jig-003-machines.md](jig-003-machines.md): WorkOrder, WorkProduct, Release, Deployment, and their couplings (draft)
- [jig-004-outside.md](jig-004-outside.md): acts taken outside jig, their mapping, and the evidence they leave (draft)
- jig-005, recording: [#130](https://github.com/empowerite/jig/issues/130)

# Docs

How to install, use and extend jig, in the present tense. A page here describes what jig is and does today. The
decisions behind it are the job of `specs/`, and a user never needs to open that directory; an extender needs both.

## Discipline

- A page describes the current state. It carries no history, no "previously", no account of how a thing came to
  be; git holds that.
- A page is written for a user or an extender, never for a designer. The reason a thing is the way it is belongs
  in its spec, and a page that needs a reason points at the spec with `see:` rather than repeating the argument.
- A page assumes a reader who has never seen this repository and has read no spec.
- A page is one of three kinds, install, use, or extend, and says which in its first line.
- A page and the code do not disagree. The pull request that changes a behavior changes the page that describes
  it.
- The writing rules in [CLAUDE.md](../CLAUDE.md) apply: plain sentences, lists where the content is a list, a blank
  line after every block.

## Index

One line per page: the file and what a reader gets from it. Empty until the first page lands.
jig will generate this index once it can; until then it is kept by hand.

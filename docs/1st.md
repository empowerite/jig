# Docs

How to install, use and extend jig, in the present tense. A page describes what jig is and does today. An RFC says
what was decided and why, and once accepted it is the spec the code is checked against; its record and its index are
[rfcs/1st.md](rfcs/1st.md). A user reads the pages and skips the RFCs; an extender reads both. Setting up a desk or a
runner to work in this repository is [README.md](../README.md).

## Pages

- A page describes the current state. It carries no history, no "previously", no account of how a thing came to
  be; git holds that.
- A page is written for a user or an extender, never for a designer. The reason a thing is the way it is belongs
  in its RFC, and a page that needs a reason points at the RFC with `see:` rather than repeating the argument.
- A page assumes a reader who has never seen this repository and has read no RFC.
- A page is one of three kinds, install, use, or extend, and says which in its first line.
- A page and the code do not disagree. The pull request that changes a behavior changes the page that describes
  it.

## Index

One line per page, kept by hand until jig generates it. There are no pages yet.

- [rfcs/1st.md](rfcs/1st.md): the RFC record and index

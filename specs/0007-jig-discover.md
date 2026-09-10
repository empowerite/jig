# jig-discover: path to rules

Status: draft

## Decision

`jig-discover` is the first extension, run as `jig discover <path>…`. Given a path, it prints the rules that bind
it: the rule files a routing table the repository commits maps to that path. It is a function of the table and the
path, and it reads nothing else.

### The table

The repository declares its routing in `jig.toml`, under `[discover]`: rows of a glob and the rule files it pulls
in, and a directory is a prefix that binds everything beneath it. Rows add; nothing overrides. For a path, the
rules are the union of every row it matches, printed general before specific, so a session reads the broad rule
before the narrow one that refines it. A rule file is Markdown, wherever the repository keeps it, and its first
line says what it governs.

### What it prints

- `jig discover <path>`: the rule files' contents, each once, general before specific.
- `jig discover --paths <path>`: their paths only.
- `jig discover --audit`: every file kind in the tree no row matches, with a count and one example, so silence is
  counted rather than merely met.

An unmatched path binds nothing, and the answer says so. It invents no rule; what governs an unmatched kind is a
person's decision, made by adding a row.

### Delivery

The harness port of [0002-ports.md](0002-ports.md) carries the answer to the session without being asked: a Claude
Code hook runs `jig discover` after every read and edit and hands the session each rule file once per session; a
Cursor rule file is generated from the table, one glob-attached rule per row. The table is the one source and the
adapters are derived from it.

### The seat

`jig-discover` attaches at the rule-source point of [0006-extensions.md](0006-extensions.md). It runs in a tick
only to answer `jig context`'s question about the paths a change touches; it takes no transition.

## Why

- Computed, not hunted, because a rule a session must find by searching is one it will find only when it thinks to
  look, and the rules that matter most are the ones it did not know existed.
- Union and never override, because a narrow rule that silently replaced a broad one would let a subtree opt out
  of a repository's law by declaring something about itself.
- Silence said aloud, because an unmatched path answered with nothing is indistinguishable from a matched path
  with no rules, and only one of those is a decision someone made.
- One table and derived adapters, because two harnesses given two hand-kept lists of rules will disagree by the
  end of the week.

## Consequences

- `CLAUDE.md` sheds its "what to read" guidance to this extension; the loop's file becomes a pointer.
- `jig context`, [0008-jig-context.md][0008], includes the rules for the paths a change touches by calling this.
- The `[discover]` table is validated by `jig policy check`: every rule file it names exists.

## Open questions

- Whether a rule file may declare a normative core that `--brief` prints alone, so that a session pays for the
  rule and not the argument; the shape of that declaration.
- Whether the table lives in `jig.toml` or beside the rules it routes, one table per subtree.

[0008]: https://github.com/empowerite/jig/issues/13

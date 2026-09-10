# jig-discover: path to rules

Status: draft

## Decision

`jig-discover` is the first extension, run as `jig discover <path>…`. Given a path, it prints the rules that bind
it: every rule file whose declared globs match it. It is a function of the rule files and the path, and it reads
nothing else.

### The rule file

A rule file is Markdown with YAML front matter, wherever the repository keeps it, and the front matter is what
`jig discover` reads:

```yaml
---
scope: what this file governs, in one sentence a session can decide from
applies: [globs the rule binds, relative to the rule file's directory]
---
```

`scope` is required. `applies` is the routing: a path binds a rule file when it matches one of that file's globs.
Rows add; nothing overrides. For a path, the rules are the union of every file whose glob it matches, printed
general before specific, shallower file first, so a session reads a repository's rule before the subtree's rule
that refines it. There is no central table; the tree is the table.

### What it prints

- `jig discover <path>`: the repository-relative paths of the rule files that bind it, one per line, general
  before specific, and nothing else; the caller reads the files.
- `jig discover --audit`: every file kind in the tree no row matches, with a count and one example, so silence is
  counted rather than merely met.

An unmatched path binds nothing, and the answer says so. It invents no rule; what governs an unmatched kind is a
person's decision, made by adding a row.

### Delivery

The harness port of [rfc-002-ports.md](rfc-002-ports.md) carries the answer to the session without being asked: a Claude
Code hook runs `jig discover` after every read and edit and hands the session the files it names, each once per
session; a
Cursor rule file is generated from the front matter, one glob-attached rule per rule file. The rule files are the
one source and the adapters are derived from them.

### The seat

`jig-discover` attaches at the rule-source point of [rfc-006-extensions.md](rfc-006-extensions.md). It runs in a tick
only to answer `jig context`'s question about the paths a change touches; it takes no transition.

## Why

- Computed, not hunted, because a rule a session must find by searching is one it will find only when it thinks to
  look, and the rules that matter most are the ones it did not know existed.
- Union and never override, because a narrow rule that silently replaced a broad one would let a subtree opt out
  of a repository's law by declaring something about itself.
- Silence said aloud, because an unmatched path answered with nothing is indistinguishable from a matched path
  with no rules, and only one of those is a decision someone made.
- Front matter and not prose, because a machine routes on a field and a person reads a sentence, and one file can
  carry both.
- The tree as the table, because a routing table kept apart from the rules it routes is a second thing to keep in
  step, and the rule that forgot its row is the one nobody finds.
- Derived adapters, because two harnesses given two hand-kept lists of rules will disagree by the end of the week.

## Consequences

- `CLAUDE.md` sheds its "what to read" guidance to this extension; the loop's file becomes a pointer.
- `jig context`, [rfc-008-jig-context.md](rfc-008-jig-context.md), includes the rules for the paths a change touches by
  calling this.
- `jig policy check` validates every rule file's front matter: `scope` present, `applies` globs well formed.

## Open questions

- Whether a rule file may declare a normative core that `--brief` prints alone, so that a session pays for the
  rule and not the argument; the shape of that declaration.
- Whether a rule file may also name other rule files it entails, so a general rule can pull a specific one in
  without the specific one repeating the globs.

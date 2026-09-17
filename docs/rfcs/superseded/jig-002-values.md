# Values: an instance of a type, at a version

Status: draft

## Decision

A value is an instance of a type of [jig-001-types.md](jig-001-types.md). It is whatever the port reads at the type's
location, and it is judged against the type's name rule and shape from the moment it is read. A file in a directory,
an issue in a tracker, a pull request, a tag, a policy declaration: each is a value of the type whose location holds
it, and jig holds no instance of anything that is not.

### The version

Every value has a version, and a version names one content. Which fact is the version is the type's to say, and the
standard types say:

- A file or a tree: its digest.
- A change: its head commit.
- A provider object with a version of its own, a review or a check run: that version.
- A work item: its submission count. An edit to the body does not advance it, and a comment is not an edit; only
  the submit action does. A work item that has been changed and not resubmitted is at its old version.

A new version is a new content for every judgment made about the value, and nothing judged at the old version is
carried to the new one.

### Facts

A fact is a value too: something a port reads that is not itself an instance of a declared type, but is about one.
Time is a fact. A need, something published as owed on a value, is a fact. A label, a review, a check's result, a
push are facts about the value they attach to. Facts are read, never declared, and a policy names them only in a
condition or a guard.

```json
{
  "type":     "change",
  "identity": "github.com/empowerite/jig#98",
  "version":  "commit:9a3f2c1e",
  "shape":    {"title": "#96 RFCs move to docs/rfcs/", "target": "main", "draft": false},
  "facts": {
    "time":    "2026-09-11T06:12:40Z",
    "labels":  ["change:flagged"],
    "reviews": [{"by": "jeffrey-aguilera", "state": "changes_requested", "commit": "9a3f2c1e"}],
    "checks":  [{"name": "default-branch", "conclusion": "failure", "commit": "9a3f2c1e"}],
    "needs":   [{"owed_by": "author", "what": "fix the link, or write the file it names, then push"}]
  }
}
```

## Why

- A value is what the port reads, and nothing else, because the provider owns every fact and jig holds no record a
  provider could contradict.
- A version names one content because a judgment is over a content, and a value whose version could stay while its
  content changed would let an old judgment stand for a new content.
- A work item's version is its submission count, and not its body, because a body edit is too fine a version: a typo
  fix would discard every judgment made, and the substantive answer to a judgment often arrives as a comment, which is
  not an edit at all. The submit is the one act that says the author is ready to be judged again.
- Time and need are facts rather than anything of their own because each is an input to the same jobs a lifecycle
  already does, and a fourth thing would be a fourth job.

## Consequences

- A gate of [jig-003-gates.md](jig-003-gates.md) judges a value at a version, and its verdict is keyed by that
  version.
- A derived state of [jig-004-lifecycles.md](jig-004-lifecycles.md) is a condition over the facts of a value.
- The view the engine of [jig-008-engine.md](jig-008-engine.md) reads is the values of every declared type, at their
  versions, with their facts.
- The exported document of [jig-009-language.md](jig-009-language.md) is the concrete form of a value.
- The work port of [jig-006-ports.md](jig-006-ports.md) carries a work item's submission count, since no tracker holds
  one natively; where it is kept is that port's to say.

## Open questions

- Whether a comment on a work item is a fact of the item, or a value of a type of its own.
- What the version of a value with no natural one is, a tracker object with no revision and no submit, and whether
  the type may declare the whole content as its version.

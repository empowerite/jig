# jig-context: state to brief

Status: draft

## Decision

`jig-context` is the first extension, run as `jig context <N>`. Given the number of an instance, a work item unless a
type is named, it prints the brief: everything an actor about to work on it needs, computed from the view and the
chain in force, and nothing an actor should have to infer.

### The brief

- The instance: its type, its state, its attributes, its relations, and who holds it.
- Its changes, for a work item: each one's state, its verdicts, its batch if any, and its bindings.
- The legal moves from here: each acted transition the lifecycle allows, with its guard as it stands, every gate
  green, red or missing and by what, and who may take it under the chain in force.
- The gates that will judge the paths the change touches, from the globs the policy attaches to them, each once, with
  what it checks and its remedy.
- What blocks it: the relation it waits on, the gate that is red, the verdict that is missing, the hold a person set.

For a session scoped to one item, standing in that change's worktree, the brief is the procedure. It says the change
the session stands on, its state, the legal moves, and what each requires, so the session reads no written procedure
and is never told a step the machine can tell it.

### The needs

`jig context --needs` prints what the board wants done and has no one doing: a change whose verdict is red and
whose owner has not moved; a work item whose blockers all closed; a change admissible and waiting for a person's
landing. Each need names the item, the state, and what would satisfy it. jig publishes needs; who acts on a need
is never its decision, and this extension starts nothing.

### Where it is served

On the command line, as text and as `--json`; over the MCP server of
[jig-006-operator-surface.md](jig-006-operator-surface.md), as a tool and as a resource per item; and through the
harness port at session start, so a session that opens with an item in hand is handed its brief before its first
question.

### The seat

`jig-context` attaches at the brief-source point of [jig-007-extensions.md](jig-007-extensions.md). It reads the view
and the chain in force through the public model; it takes no transition and writes nothing.

## Why

- A function, not a document, because a state machine a session reads to find its own position costs tokens on
  every read and is wrong the moment the machine changes; a brief costs one call and is computed from the machine.
- Legal moves with their gates, because "what may I do next" is the question every actor asks first and the one
  no provider answers.
- Needs published and never dispatched, because agents call jig, and a jig that started an actor would own a
  process it cannot see.

## Consequences

- `CLAUDE.md` sheds its account of states and moves; the loop's file becomes a pointer.
- The interface's item view of `jig-006` is this brief drawn.
- The dispatcher of [jig-007-extensions.md](jig-007-extensions.md) polls `jig context --needs`; jig ships one
  reference dispatcher and starts nothing itself.

## Open questions

- The brief's size: whether a gate's remedy text is inlined or referenced past a budget, and who sets the budget.
- Whether the needs feed is also written to the provider, as a comment or a label, so a person without jig sees it.

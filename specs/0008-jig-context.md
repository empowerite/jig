# jig-context: state to brief

Status: draft

## Decision

`jig-context` is the second extension, run as `jig context <N>`. Given a work item's number, it prints the brief:
everything an actor about to work on it needs, computed from the view and the policy, and nothing an actor should
have to infer.

### The brief

- The work item: its state, its attributes, its relations, and who holds it.
- Its changes: each one's state, its verdicts, its batch if any, and its bindings.
- The legal moves from here: each transition the lifecycle allows, with its gate as it stands, met or not and by
  what, and who may take it under this repository's policy.
- The rules for the paths the change touches, by way of `jig discover`, each once.
- What blocks it: the relation it waits on, the gate that is red, the hold a person set.

### The needs

`jig context --needs` prints what the board wants done and has no one doing: a change whose verdict is red and
whose owner has not moved; a work item whose blockers all closed; a change admissible and waiting for a person's
landing. Each need names the item, the state, and what would satisfy it. jig publishes needs; who acts on a need
is never its decision, and this extension starts nothing.

### Where it is served

On the command line, as text and as `--json`; over the MCP server of
[0005-operator-surface.md](0005-operator-surface.md), as a tool and as a resource per item; and through the
harness port at session start, so a session that opens with an item in hand is handed its brief before its first
question.

### The seat

`jig-context` attaches at the brief-source point of [0006-extensions.md](0006-extensions.md). It reads the view
and the policy through the public model and calls `jig discover` for the rules; it takes no transition and writes
nothing.

## Why

- A function, not a document, because a state machine a session reads to find its own position costs tokens on
  every read and is wrong the moment the machine changes; a brief costs one call and is computed from the machine.
- Legal moves with their gates, because "what may I do next" is the question every actor asks first and the one
  no provider answers.
- Needs published and never dispatched, because agents call jig, and a jig that started an actor would own a
  process it cannot see.

## Consequences

- `CLAUDE.md` sheds its account of states and moves; the loop's file becomes a pointer.
- The interface's item view of `0005` is this brief drawn.
- A future dispatcher, whoever writes one, polls `jig context --needs` and is outside jig.

## Open questions

- The brief's size: whether rule text is inlined or referenced past a budget, and who sets the budget.
- Whether the needs feed is also written to the provider, as a comment or a label, so a person without jig sees it.

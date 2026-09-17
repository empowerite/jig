# The desk and the checkout: where jig runs, and at which version

Status: draft

## Decision

jig runs in two kinds of process on a desk, and the split follows what each depends on. What depends on a policy
runs at the version the checkout pins. What depends on the host, the editor, the agent harness, the person at the
keyboard, runs once per desk at the newest version installed.

### The checkout's process

Every checkout jig serves, a clone or a worktree, runs its own jig at the version that checkout pins through its
tool file. Deciding and recording, the components of [jig-000-charter.md](jig-000-charter.md) whose meaning depends
on the policy in force, run here and nowhere else. A worktree that pins the next jig runs it beside the one the
main checkout pins, so one repository is two of these processes when it needs to be, and nothing either does
depends on the other.

### The desk's process

One process per user on a machine serves presenting for every checkout that desk has opened: the browser interface,
the MCP server the agent harness connects to, and the command line's view across checkouts. It runs at the newest
jig installed on the desk. It starts a checkout's process on demand, at that checkout's pinned version, and speaks
to it over a narrow protocol whose version is part of the message, so a desk process is required to understand every
checkout process it starts and refuses one it cannot.

### Starting, joining, leaving

- Nothing is installed beyond the binary. Any invocation of `jig` that needs the desk, the command line, the
  interface, the stdio client an agent harness launches, connects to a per-user socket and starts the desk process if
  nothing answers.
- A client announces the checkout it stands in, and the checkout joins the desk. It leaves when its last client is
  gone and the checkout has not been touched for a while. A workspace with several checkouts, or several windows on
  one, is clients coming and going, nothing more.
- A client newer than the desk process asks it to re-exec the newest installed binary, so the desk is always at
  least as new as any client.

### Versions

- A checkout pins the binary, in its tool file, the way it pins every other tool. A desk holds as many versions as
  its checkouts pin.
- The protocol between the desk process and a checkout process is versioned on its own, and a change to it is a
  major release of the binary.
- The record a checkout process writes is readable by every later version, since the desk process reads every
  checkout's record.

## Why

- Two kinds of process because the two dependencies pull apart. A policy's meaning depends on the engine that reads
  it, so a repository must be able to pin the engine, and a worktree trying the next version must run it beside the
  old one. The interface and the MCP server depend on the host, and the host is one per desk, whatever the
  workspace holds. A single process would have to be pinned per checkout and shared per desk at once.
- On demand rather than a service manager because nothing then has to be installed, a workspace changing shape is
  ordinary, and the re-exec rule keeps the daemon current without anything restarting it.
- One desk process per user rather than one per editor window because a machine's checkouts do not belong to a
  window, and an aggregate view across them has to live somewhere that outlives any one of them.
- The record readable by every later version because the desk process is newer than the checkout processes it
  reads, always, and a record that only its writer could read would be no record.

## Consequences

- The command line, the interface and the MCP server of presenting are served by the desk process; a checkout
  process has no surface of its own beyond the protocol.
- A checkout's tool file pins `jig`; the desk process is whichever installed version is newest.
- Identity on a desk, who the person is and how a session acts for them against the provider, is the remote half of
  this runtime and its own RFC.
- The aggregate view across many desks is a later service, as the charter leaves it.

## Open questions

- The protocol's shape: whether it is the GraphQL schema the surfaces already speak, narrowed, or something smaller.
- How long a checkout stays joined after its last client leaves.
- Whether a checkout process may outlive the desk process, for a long-running gate, and who reaps it.

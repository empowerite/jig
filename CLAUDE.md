# Working in this repository

jig is a policy engine over declared entity types, and the software development lifecycle is the standard policy it
ships. [jig-000-charter.md](docs/rfcs/jig-000-charter.md) is the charter and says what that means and what jig is not.
This file says how work moves here until jig can say so itself. Each paragraph below is a job jig will take over, and
when it does, the paragraph goes.

## The loop

Every change begins as an issue and ends as a pull request a maintainer merges. Nothing reaches `main` any other
way.

1. Open an issue. Say why before what. A change without an issue has not started.
2. Wait for `accepted`. A person reads the issue and labels it `accepted` or `rejected`, and work begins only on an
   accepted one. A session that reaches an issue without the label stops there and says so. Before starting, it
   says in one line what it is about to build, so a misread issue is caught before the work.
3. Branch from `main` and check the branch out in a worktree, `worktrees/<N>-<slug>`, made with `git worktree add`.
   The directory is ignored, so it never appears in a status or a commit. Name the branch as you like; `<N>-<slug>` is
   a habit, not a rule.
4. Commit with a signed commit. The subject is `#<N> <what changed>`, under 72 characters. The body says why, in plain
   prose. The branch ruleset rejects an unsigned commit; the one-time setup is in [README.md](README.md), under Setup.
5. Open a pull request and link the issue under Development in its sidebar. A session working through the API
   makes the same link with the `addCloseIssueReferences` mutation. The link is what counts, and the check on `main`
   reads only that. The pull request is the report: what changed, what was checked, and what was left out and why.
   Call nothing merged, landed or done until the merge is observed.
6. A maintainer reviews and merges, by squash or rebase. A merge to `main` is never automatic: it happens on a
   maintainer's request, or as the landing step of a transition that owns the merge. The ruleset requires linear
   history, so there are no merge commits.

## Labels

- `accepted`: a person read the issue and wants it built. Work begins only after it.
- `rejected`: a person read the issue and it does not stand as written. Rework it; it can be accepted afterward.
- `parked`: a person's hold, on an issue or a pull request. Nothing moves until it comes off.

Anyone may file an issue; a person decides. Until jig enforces it, a session sets none of these on its own.

## RFC first

The charter names the parts. Each part gets an RFC in `docs/rfcs/`, `jig-NNN-<slug>.md`, before its code, and an
accepted RFC is the spec the code is checked against. The pages in `docs/` describe how to install, use and extend
jig, in the present tense and without history. An RFC the code has left behind is corrected, or marked superseded, in
the same change that left it.

## Writing

Write plain declarative sentences with the thing under discussion as the subject. Use a list where the content is a
list. Do not bold words for emphasis. Do not close a paragraph on a slogan. Describe the current state and leave the
history to git.

## Provenance

This repository has no predecessor. Ideas arrive here as principles. No file, comment, or commit message names
another project as the source of a rule.

## Status

There is no code yet. Nothing here builds, tests, or runs.

# Working in this repository

jig is a control plane for the software development lifecycle. [README.md](README.md) is the charter and says what
that means. This file says how work moves here until jig can say so itself. Each paragraph below is a job jig will
take over, and when it does, the paragraph goes.

## The loop

Every change begins as a ticket and ends as a pull request a maintainer merges. Nothing reaches `main` any other way.

1. Open a ticket. Say why before what. A change without a ticket has not started.
2. Branch from `main` as `<N>-<slug>`, where `<N>` is the ticket number. One ticket, one branch. A worktree is fine.
3. Commit with a signed commit. The subject is `#<N> <what changed>`, under 72 characters. The body says why, in
   plain prose. The branch ruleset rejects an unsigned commit, so a fresh clone needs this once:

   ```sh
   git config gpg.format openpgp
   git config user.signingkey <a key GitHub verifies for you>
   git config commit.gpgsign true
   ```

4. Open a pull request whose body begins `Closes #<N>`. The pull request is the report: what changed, what was
   checked, and what was left out and why. Call nothing merged, landed or done until the merge is observed.
5. A maintainer reviews and merges, by squash or rebase. The ruleset requires linear history, so there are no merge
   commits.

## Spec first

The charter names the parts. Each part gets a spec in `specs/` before its code, and the code is checked against the
spec. `docs/` describes how to install, use and extend jig, in the present tense and without history. A spec the code
has left behind is corrected, or marked superseded, in the same change that left it.

## Writing

Write plain declarative sentences with the thing under discussion as the subject. Use a list where the content is a
list. Do not bold words for emphasis. Do not close a paragraph on a slogan. Describe the current state and leave the
history to git.

## Provenance

This repository has no predecessor. Ideas arrive here as principles. No file, comment, or commit message names
another project as the source of a rule.

## Status

There is no code yet. Nothing here builds, tests, or runs.

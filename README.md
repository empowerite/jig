# jig

jig is a policy engine over declared entity types, and the software development lifecycle is the standard policy it
ships. What that means, and what jig is not, is [jig-000-charter.md](docs/rfcs/jig-000-charter.md).

## Install

`mise.toml` at the root pins every tool the repository runs, and `mise.lock` records the exact versions. A desk and a
runner install from the same two files, so a check that passes on one passes on the other.

1. Install `mise`; see: [mise.jdx.dev](https://mise.jdx.dev/getting-started.html).
2. In the clone, once: `mise trust`.
3. Then: `mise install`.

Activate `mise` in the shell, or prefix a command with `mise exec --`, and the pinned tools answer by their bare
names. A runner does the same through `jdx/mise-action` in the workflow; nothing is installed by hand there.

What is pinned:

- `actionlint`: lints the workflows and runs shellcheck over the scripts inside them.
- `lychee`: checks that the links in the docs resolve.
- `gh` and `jq`: what the policy checks call.

## Setup

Every commit is signed, and the branch ruleset refuses one that is not. Once per clone:

```sh
git config gpg.format openpgp
git config user.signingkey <a key GitHub verifies for you>
git config commit.gpgsign true
```

## Getting started

Work here moves by the loop in [CLAUDE.md](CLAUDE.md): an issue, the `accepted` label, a branch checked out in a
worktree under `worktrees/`, a signed commit, a pull request linked to its issue, a maintainer's merge. The checks a
pull request must pass are the steps of the workflow in `.github/workflows/`, one per policy. The record behind every
rule is `docs/rfcs/`, indexed in [docs/rfcs/1st.md](docs/rfcs/1st.md).

## Status

Pre-alpha. There is no code yet, so nothing here builds, tests or runs. The repository will run on jig as soon as jig
can run it.

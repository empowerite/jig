# Install

An install page: what a desk and a runner need in order to work in this repository, and how they get it.

## The toolchain

`mise.toml` at the root pins every tool the repository runs, and `mise.lock` records the exact versions. A desk and
a runner install from the same two files, so a check that passes on one passes on the other.

1. Install `mise`; see: [mise.jdx.dev](https://mise.jdx.dev/getting-started.html).
2. In the clone, once: `mise trust`.
3. Then: `mise install`.
4. And: `git config core.hooksPath controls/hooks`, so that every commit runs the pre-commit controls; see
   [controls/1st.md](../controls/1st.md).

Activate `mise` in the shell, or prefix a command with `mise exec --`, and the pinned tools answer by their bare
names. A runner does the same through `jdx/mise-action` in the workflow; nothing is installed by hand there.

## What is pinned

- `actionlint`: lints the workflows and runs shellcheck over the scripts inside them.
- `lychee`: checks that the links in docs and specs resolve.
- `gh` and `jq`: what the policy checks call.

## Signing

Every commit is signed, and the branch ruleset refuses one that is not; the one-time setup is in
[CLAUDE.md](../CLAUDE.md), step 4.

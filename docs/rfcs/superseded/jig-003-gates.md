# Gates: one judgment over one value at one version, and the attested verdict

Status: draft

## Decision

A gate judges a value of [jig-002-values.md](jig-002-values.md). Its result is a verdict: the result of evaluating one
gate over one value, keyed by the gate's identity and the value's version. A new version needs a new verdict. A gate
whose own definition changed, which is a change in the digest of the policy that declared it, has stale verdicts; a
change elsewhere in the chain leaves them standing. A second verdict by the same gate on the same version supersedes
the first, and the record keeps both.

Two producers yield one record.

- A rule gate is evaluated by the engine over facts it already holds, at once.
- A verdict gate is run by something: a command on a desk, a check on the provider, an extension in a tick. Whatever
  reads its result never runs it.

Every verdict carries the subject, as type, identity and version; the gate, by name and by the digest of the policy
that declared it; the conclusion, which is pass, fail or unknown; the evidence, which is the annotations, the
artifacts and the remedy, and the remedy names who owes what; the evaluator, which is jig's version for a rule gate
and the tool and its version for a verdict gate; every link of the chain in force, by digest; the time; and a
signature by the actor that produced it, a person's key on a desk and the bot's key for a jigbot.

A verdict carries no severity. Whether a fail is a warning or a refusal is decided by where the verdict is demanded,
and the same record is one thing in one place and the other in another.

```json
{
  "subject":    {"type": "change", "identity": "github.com/empowerite/jig#98", "version": "commit:9a3f2c1e"},
  "gate":       {"name": "tests", "link": "github.com/empowerite/policy@v0.1.2", "digest": "sha256:e07a…"},
  "conclusion": "fail",
  "evidence": {
    "annotations": [{"path": "docs/1st.md", "line": 43, "message": "link does not resolve: ../CLAUDE.md#setup"}],
    "artifacts":   ["https://github.com/empowerite/jig/actions/runs/34569964919"],
    "remedy":      {"owed_by": "author", "what": "fix the link, or write the file it names, then push"}
  },
  "evaluator":  {"tool": "lychee", "version": "0.24.0"},
  "chain":      ["jig.dev/std@v0.3.0 sha256:4b1c…",
                 "github.com/empowerite/policy@v0.1.2 sha256:e07a…",
                 "./ sha256:91d0…"],
  "time":       "2026-09-11T06:12:40Z",
  "signature":  {"by": "jeffrey-aguilera", "key": "24BCD9AB0BC427A1", "sig": "…"}
}
```

### The attestation

An attestation is a verdict written as an in-toto statement and signed in the DSSE envelope, so that anything outside
jig can verify it. A transition taken is attested once more, as a statement naming the verdicts it required. Both are
stored through the port in the slot the provider offers: an attestation store keyed by digest where the provider has
one, a ref or a note where it does not, a comment last. The provider owns them, as it owns every other fact.

```json
{
  "_type":         "https://in-toto.io/Statement/v1",
  "subject":       [{"name": "github.com/empowerite/jig#98", "digest": {"gitCommit": "9a3f2c1e…"}}],
  "predicateType": "https://jig.dev/verdict/v1",
  "predicate":     {"gate": "…", "conclusion": "fail", "evidence": "…", "evaluator": "…", "chain": "…", "time": "…"}
}
```

```json
{
  "payloadType": "application/vnd.in-toto+json",
  "payload":     "eyJfdHlwZSI6Imh0dHBzOi8vaW4tdG90by5pby9TdGF0ZW1lbnQvdjEiLCJzdWJqZWN0Ijpb…",
  "signatures":  [{"keyid": "24BCD9AB0BC427A1", "sig": "…"}]
}
```

Whether every aspect of the policy was applied to a value is then a query and not a search: the transition's
statement, the chain digests it names, and the verdicts it names, each signed. A verdict written once is read
wherever it is demanded, and a gate demanded on a version that already carries its verdict is not run again.

## Why

- A verdict is keyed by gate and version because it is one judgment over one content, and any other key would let a
  stale judgment stand for a new content or a changed rule.
- The latest verdict supersedes because a reviewer who changes their mind has made a new judgment over the same
  content, and the argument about a judgment belongs where the judgment is made, with the reviewer, and not in a
  resubmission of unchanged content.
- A verdict carries no severity because the same judgment is a warning long before the transition that will demand it
  and a refusal there, and a severity in the record would have to be rewritten as the value moved.
- The remedy names who owes what because the reader of a fail is the one the remedy addresses, and a fail that names
  nobody sends the author looking for something that is not theirs.
- A verdict carries the chain and a signature because an audit asks what was in force and who said so, and a check run
  says only that a tool ran.
- The statement format is in-toto in a DSSE envelope because a record only jig can verify is a record nobody outside
  jig can trust, and both are what existing attestation stores already hold.

## Consequences

- A guard of [jig-004-lifecycles.md](jig-004-lifecycles.md) names gates and reads their verdicts, and a derived state
  there is what a fail looks like on the value.
- The ports of [jig-006-ports.md](jig-006-ports.md) gain the production of a verdict on request and a slot per
  provider for attestations; see [#69][ports].
- `jig verify` of [jig-011-operator-surface.md](jig-011-operator-surface.md) produces the verdicts a transition is
  missing, the audit answer is a verb, and a verdict not yet demanded is rendered as a warning naming the value, the
  transition that will refuse it and the remedy.
- A gate extension of [jig-010-extensions.md](jig-010-extensions.md) returns the verdict record above; see
  [#71][extensions].
- The brief of [jig-012-jig-context.md](jig-012-jig-context.md) names the gates that will judge the paths a change
  touches; see [#73][context].

## Open questions

- Whose key signs a verdict and how a consumer verifies it; with releases, in jig-013.
- What the in-toto statement's subject carries and what its predicate carries.

[ports]: https://github.com/empowerite/jig/issues/69
[extensions]: https://github.com/empowerite/jig/issues/71
[context]: https://github.com/empowerite/jig/issues/73

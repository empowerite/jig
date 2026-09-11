# Language: what a policy is written in

Status: draft

## Decision

A policy is written in two languages with one seam between them, and its text is rendered by a third. CUE declares and
composes. Rego, evaluated by OPA, decides. Jinja2 renders every text jig emits. The seam is one document: the policy
CUE exports, which Rego reads as data. All three evaluators are embedded in the `jig` binary, and a consumer installs
none of them.

### Declarations, in CUE

A type of [jig-001-types.md](jig-001-types.md) is a CUE definition. Its identity, its location as a port and a place,
its name rule as a regular-expression constraint, its shape as a definition with constraints, its lifecycle as a value
built from the kinds, and its actions naming the capabilities they take and the templates they fill are all fields of
that definition, and an instance is validated by unifying what the port read with the definition.

The chain is CUE modules. A policy is a module. A pull is a dependency the module file pins by version and the
registry resolves by content digest. jig's standard policy is a module, an organization's is a module, and the
repository's own policy is the module at its root that imports the ones it pulls in.

Composition is unification. A refinement narrows because unification only narrows, and a contradiction is bottom,
which CUE reports naming both positions. The two structural rules unification does not express, that a type is
declared by exactly one link and that a refinement adds no state, transition or actor to a lifecycle declared above
it, are checked over the exported document by rules jig ships.

The ordinary repository writes CUE data and nothing else: which modules it pulls in, its bindings, the types that are
its own, and the gates it attaches. It writes no rule.

### Decisions, in Rego

The exported document is OPA's `data` and the view is its `input`. jig ships the standard rules: the guard of every
acted transition, the actor rules, the well-formedness of a lifecycle, the structural checks of the chain, and the
rule gates the standard types need. The engine's `next` of [jig-005-engine.md](jig-005-engine.md) is a query over
them, and a tick calls it once.

A rule gate, a predicate over facts jig already holds, is Rego. jig ships those the standard types need; an extension
may ship more; a policy names the ones it attaches. Every refusal names the rule that fired and the facts it read,
which is what an attestation's predicate records. The standard rules are tested with `opa test` over fixtures,
offline, and the declarations with `cue vet`.

### Text, in Jinja2

One renderer serves every text jig emits: the body of a file-backed instance from its template, the scaffold of a type
declaration, the body of a provider-backed instance before the port files it, the remedy in a refusal, the brief's
prose, and the pointer `jig init` writes into a harness file. The values a template renders come out of CUE. The
template never computes and the policy never formats. Placing an instance is the port's act. The renderer is a Go
implementation of Jinja2, and the dialect jig promises is the subset that implementation renders, named on the pages,
since a template that leans on a Python-side filter will not render.

### The seam

The exported document has a schema jig fixes and versions with the model; the types of jig-001 are its shape. `jig
policy check` runs CUE first, vet and export, then the structural rules over the export, and reports whichever fails
first with that language's own error: a CUE error names positions, a Rego refusal names the rule and the facts. `jig
policy plan` evaluates the standard rules over both exports against the view and prints the difference.

## Why

- Two languages with a seam, because each requirement of jig-001 has a native home in one of them and a convention in
  the other, and a seam between two native homes costs less than a convention for the lattice or for the decisions.
- CUE for declarations, because unification is the composition rule of jig-001 as a language semantics rather than a
  check, and its registry is the marketplace a published policy needs.
- Rego for decisions, because a refusal that names the rule and the facts is the property asked for first, and a rule
  gate over the whole board needs joins that a constraint language does not have.
- Jinja2 for text, because it is the template language people already know, and a template plus a set of answers is
  the shape every creating action has.
- Data only for the ordinary repository, because a repository that had to write a rule to adopt a policy would not
  adopt it.
- Embedded, because a policy that needs a toolchain to evaluate is one two clones at one commit will evaluate
  differently, and the desk and the runner must run the same bytes.

## Consequences

- The declarations of [jig-001-types.md](jig-001-types.md) have a concrete form: the standard policy is a CUE module
  and the standard rules are a Rego bundle, both versioned and released with the binary; see
  [jig-010-release.md](jig-010-release.md).
- The ports of [jig-003-ports.md](jig-003-ports.md) read a repository's bindings from the exported document.
- The tick of [jig-005-engine.md](jig-005-engine.md) calls `next` as a query over the standard rules.
- The verbs of [jig-006-operator-surface.md](jig-006-operator-surface.md) run CUE then Rego for `policy check` and
  `policy plan`, and `explain` renders a declaration through Jinja2.
- An extension of [jig-007-extensions.md](jig-007-extensions.md) may ship rule gates in Rego and templates in Jinja2.
- The install page gains nothing: a consumer installs `jig` and no evaluator.

## Open questions

- Which Go implementation of Jinja2, and the dialect subset the pages promise.
- Whether a repository ever writes Rego of its own, or only names the rule gates that jig and extensions ship.
- Where the module registry lives, and whether an organization runs its own.
- Whether the well-formedness of a lifecycle is a CUE constraint, a Rego rule, or both, one for the author and one for
  the engine.
- How a CUE error and a Rego refusal are shown as one kind of thing on the operator surface.

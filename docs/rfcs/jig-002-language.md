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

```cue
// jig.dev/std: the definition every type unifies with; the six things of jig-001 are its fields
package std

#Type: {
	identity: string                    // the field that tells one instance from every other
	location: {port: string, place: string}
	name:     string                    // a regular expression an instance's name matches
	#shape:   {...}                     // an instance unifies with it; a definition, so the export stays concrete
	lifecycle: {
		initial: string
		states: [string]: {
			kind: "ground" | "derived" | "excited"
			if kind == "derived" {condition: string}
			if kind == "excited" {completes: string, fails: string}
		}
		transitions: [string]: {
			from: string, to: string
			kind: "silent" | "acted"
			if kind == "silent" {when: string}
			if kind == "acted" {action: string, actor: string, gates: [string]: #Gate}
		}
	}
	actions: create: {action: string, template?: string}
}

#Gate: {run: string} | {check: string} | {rule: string} // a desk command, a provider check, or a rule jig holds
```

```cue
// jig.dev/std: the standard work item, declared against #Type; a provider-backed type, so the tracker names it
types: "work-item": #Type & {
	identity: "number"
	location: {port: "work", place: "issues"}
	name:     #"^.+$"#
	#shape: {title: string, body: string, labels: [...string]}
	lifecycle: {
		initial: "filed"
		states: {filed: kind: "ground", assigned: kind: "ground", resolved: kind: "ground"}
		transitions: {
			assign:  {from: "filed", to: "assigned", kind: "acted", action: "assign", actor: "maintainer"}
			resolve: {from: "assigned", to: "resolved", kind: "acted", action: "close", actor: "assignee"}
		}
	}
	actions: create: {action: "file", template: "templates/work-item.md.j2"}
}
```

The chain is CUE modules. A policy is a module. A pull is a dependency the module file pins by version and the
registry resolves by content digest. jig's standard policy is a module, an organization's is a module, and the
repository's own policy is the module at its root that imports the ones it pulls in.

```cue
// cue.mod/module.cue, the repository's link: what it pulls in, pinned by version; the registry resolves the digest
module: "github.com/empowerite/jig@v0"
language: version: "v0.11.0"
deps: {
	"jig.dev/std@v0":                  v: "v0.3.0"
	"github.com/empowerite/policy@v0": v: "v0.1.2"
}
```

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

```json
// data: the exported document, cut to what the guard below reads
{"links":   [{"module": "jig.dev/std@v0.3.0", "digest": "sha256:4b1c…"},
             {"module": "github.com/empowerite/policy@v0.1.2", "digest": "sha256:e07a…"},
             {"module": "github.com/empowerite/jig", "digest": "sha256:91d0…"}],
 "types":   {"change": {"lifecycle": {"transitions": {"integrate": {"from": "admissible", "to": "integrating",
             "kind": "acted", "action": "merge", "actor": "maintainer",
             "gates": {"tests": {"run": "just test", "link": 1}}}}}}},
 "actors":  {"maintainer": ["jeffrey-aguilera"], "bot": ["empowerite-jig[bot]"]}}

// input: the view, one change and the actor asking
{"change": {"identity": "github.com/empowerite/jig#98", "digest": "tree:9a3f2c1e…", "state": "admissible",
            "draft": false, "verdicts": {"tests": {"conclusion": "fail", "digest": "tree:9a3f2c1e…"}}},
 "actor":  "jeffrey-aguilera"}
```

```rego
package jig.guard

import rego.v1

# integrate may be taken when every gate on it holds a passing verdict at the digest and the actor is allowed
allow if {
	t := data.types.change.lifecycle.transitions.integrate
	every name, _ in t.gates {
		v := input.change.verdicts[name]
		v.digest == input.change.digest
		v.conclusion == "pass"
	}
	input.actor in data.actors[t.actor]
}

# every refusal names the rule that fired and the facts it read
refusal contains msg if {
	some name, gate in data.types.change.lifecycle.transitions.integrate.gates
	v := input.change.verdicts[name]
	v.conclusion != "pass"
	msg := sprintf("gate %q is %s at %s, attached by %s",
		[name, v.conclusion, input.change.digest, data.links[gate.link].module])
}
```

```text
$ jig integrate 98
refused: integrate on change github.com/empowerite/jig#98 at tree:9a3f2c1e…
  gate "tests" is fail at tree:9a3f2c1e…, attached by github.com/empowerite/policy@v0.1.2
  rule jig.guard.refusal, over data.types.change.lifecycle.transitions.integrate.gates and input.change.verdicts.tests
```

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

```jinja
{#- templates/rfc.md.j2, what `jig new rfc` expands; the values are the creating action's parameters -#}
# {{ title }}

Status: draft

## Decision

{{ decision }}

## Why

## Consequences

## Open questions
```

```jinja
{#- one line of `jig explain <type>`, rendered per acted transition -#}
{% for name, t in type.lifecycle.transitions | dictsort if t.kind == "acted" -%}
`jig {{ name }} {{ type.id }} <n>` takes {{ name }} from {{ t.from }} to {{ t.to }} as {{ t.actor }}
{%- if t.gates %}, once {{ t.gates | join(", ") }} {{ "is" if t.gates | length == 1 else "are" }} green{% endif %}.
{% endfor %}
```

```text
$ jig explain rfc
`jig accept rfc <n>` takes accept from draft to accepted as maintainer.
`jig supersede rfc <n>` takes supersede from accepted to superseded as maintainer.
```

### The seam

The exported document has a schema jig fixes and versions with the model; the types of jig-001 are its shape. `jig
policy check` runs CUE first, vet and export, then the structural rules over the export, and reports whichever fails
first with that language's own error: a CUE error names positions, a Rego refusal names the rule and the facts. `jig
policy plan` evaluates the standard rules over both exports against the view and prints the difference.

```text
$ jig policy plan
in force:  jig.dev/std@v0.3.0  github.com/empowerite/policy@v0.1.2  ./ sha256:91d0…
proposed:  jig.dev/std@v0.3.0  github.com/empowerite/policy@v0.1.2  ./ sha256:3c7e…
  types.change.lifecycle.transitions.integrate.gates.tests.run: "just test" -> "just test --coverage"
over the board:
  change #98  admissible -> proposed: integrate needs a new verdict for tests; the one held is under the old gate
  change #102 proposed: unchanged
1 transition waits for a verdict, 0 are refused
```

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
- How a link narrows the actors of a transition in CUE. A disjunction of logins does not export and a list does not
  unify, so the examples above give a transition one role and leave the intersection of jig-001 to a per-link list the
  export carries and jig intersects.
- The module path of the standard policy and the predicate type of a verdict, written as `jig.dev` in the examples
  until the registry question above is settled.

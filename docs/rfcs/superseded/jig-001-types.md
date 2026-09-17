# Types: the unit of policy

Status: draft

## Decision

jig is a policy engine over declared entity types. A policy declares types, and the engine is generic over what it
declares. The work item and the change of the SDLC are two types jig's standard policy declares, and a repository
declares types of its own the same way. The charter, [jig-000-charter.md](jig-000-charter.md), states the principles
this follows from and says that the lifecycle is data within fixed kinds.

### The type

A type is the unit of policy. Every type declares six things.

1. An identity: how one instance is told from every other.
2. A location: a port and a place in it. A directory through the scm port, a tracker through the work port.
3. A name rule: what an instance may be called.
4. A shape: what an instance must contain.
5. A lifecycle: the states an instance may be in and the transitions between them. What a lifecycle is made of, and
   when one is well formed, is its own RFC.
6. Actions: what creates an instance and what moves it. An action names a capability, a word in a vocabulary jig
   fixes, and a port declares which of them it offers.

A file-backed type and a provider-backed type are one model, because a location is a port either way. Work item and
change are two declarations in the standard policy jig ships, with a provider behind each. So is type itself: its
location is the repository's policy, its shape is the six things, and its creating action writes a declaration. A
type named rfc is the example a repository declares for itself: one directory, a name regex, a template as its shape
from which the creating action expands a new instance, and the states draft, accepted and superseded.

```cue
// the repository's own link: the type named rfc, all six things, in the form jig-009 fixes
package policy

import "jig.dev/std"

types: rfc: std.#Type & {
	identity: "number"
	location: {port: "scm", place: "docs/rfcs"}
	name:     #"^jig-(?P<number>\d{3})-[a-z][a-z-]*\.md$"#
	#shape: status: "draft" | "accepted" | =~#"^superseded by jig-\d{3}$"#
	lifecycle: {
		initial: "draft"
		states: {draft: kind: "ground", accepted: kind: "ground", superseded: kind: "ground"}
		transitions: {
			accept:    {from: "draft", to: "accepted", kind: "acted", action: "write", actor: "maintainer"}
			supersede: {from: "accepted", to: "superseded", kind: "acted", action: "write", actor: "maintainer"}
		}
	}
	actions: create: {action: "write", template: "templates/rfc.md.j2"}
}
```

## Why

- The type is the unit of policy because a rule with no gate behind it is prose nobody writes, and a declared type has
  teeth and pays back: it refuses variance, expands its template, and answers what it is when asked. The rule and its
  documentation are one artifact, computed from the policy that enforces it.
- File-backed and provider-backed types are one model because a location is a port either way, and two models would be
  two engines.
- A capability is a word of the type's declaration and not of the port's, because a type says what may be done to its
  instances and a port says what it can do; a policy that named a port's operations directly would be written against
  one provider.

## Consequences

- What an instance of a type is, and what its version is, is [jig-002-values.md](jig-002-values.md).
- What judges an instance is [jig-003-gates.md](jig-003-gates.md).
- What a lifecycle is made of is [jig-004-lifecycles.md](jig-004-lifecycles.md).
- How types are declared, refined and composed up a chain is [jig-005-policies.md](jig-005-policies.md).
- The ports of [jig-006-ports.md](jig-006-ports.md) gain the scm port as a location, and each port declares which
  capabilities it offers; see [#69][ports].
- What a declaration is written in, and how a published policy is packaged and pinned, is
  [jig-009-language.md](jig-009-language.md).
- The `new` verb of [jig-011-operator-surface.md](jig-011-operator-surface.md) expands a type's template, and a name
  rule that includes a sequence says so in its declaration.
- This repository declares rfc as its first type, in its own policy, once the language exists, and the record rules of
  `docs/rfcs/1st.md` become that declaration.

## Open questions

- Which capabilities each port kind offers, settled per port in jig-006.
- The identity of a file-backed instance across a rename or a move.

[ports]: https://github.com/empowerite/jig/issues/69

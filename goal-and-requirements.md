---
id: lustre-tests-goals
type: goal-and-requirements
status: draft
title: CL-Lustre-Tests goals and requirements
tags: [product]
---

# CL-Lustre-Tests

## Goal and audience

Provide a Common Lisp testing framework focused on usability and informative
reporting. Lisp developers can write ordinary functions with assertions, run them
from a REPL or ASDF/CI, and extend the framework through a small CLOS protocol
without needing to understand that protocol for everyday use.

The README establishes this goal and the assertion philosophy below. The audience
is inferred from its REPL and CI workflows; that emphasis is unconfirmed.

## Capabilities

- Define named tests and nested groups without declaring groups in advance;
  redefine tests during interactive development and find, remove, or clear them.
- Evaluate tests individually or run a hierarchy, retaining results and durations
  and distinguishing success, ignored tests, and failures.
- Continue through failures by default, or expose continuable test errors for
  interactive debugging and retrying the surrounding REPL evaluation.
- Choose declaration, reverse-declaration, or randomized ordering, and run groups
  concurrently while keeping each group's direct tests sequential.
- Produce plain REPL reports, colored terminal reports, and Open Test Reporting
  event XML; combine reporters to serve multiple outputs.
- Compare sequences with `expect-seq`, providing a bounded, optionally colored
  diff rather than requiring users to diagnose subtle sequence mismatches.
- Specialize test evaluation, result classification, sequencing, and reporting
  through the public protocol.

## Principles and scope

Common Lisp's `assert` and `check-type` are the normal assertion tools.
`expect-seq` is the deliberately focused addition: useful sequence diagnostics,
not a replacement assertion language.

Portability across Common Lisp implementations is an explicit intent, confirmed
by the maintainer. Current CI verifies SBCL on Linux, macOS, and Windows; it does
not establish that other implementations work.

Terminal/CI and REPL entry points have distinct defaults so ordinary use does not
require building a custom runner. The core behavior and its current limitations
are owned by `lustre-tests-core`; system boundaries are in
`lustre-tests-architecture`.

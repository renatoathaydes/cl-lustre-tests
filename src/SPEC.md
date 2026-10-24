---
id: lustre-tests-core
type: module-design
status: active
title: Testing protocol and runtime
parent: lustre-tests-architecture
depends-on: [lustre-tests-color-sexp, lustre-tests-time]
tags: [runtime, protocol]
---

# Testing protocol and runtime

## Responsibility and boundary

Own the public `lustre-tests` package: test definition and registration, the CLOS
extension protocol, hierarchy traversal, evaluation, sequence assertions, and
reporting. Helpers own presentation only; their dependency direction and the
external libraries are recorded in `lustre-tests-architecture`.

These contracts describe current source and test behavior, not a redesigned API.

## Registration and identity

`define-test` creates a `simple-test`, installs a function under the test's symbol,
and registers the object beneath the lazy, image-local root. `define-test!`
selects a custom test class and initargs. Parent paths are created on demand.
Redefining the same name and concrete test class under the same parent replaces
the previous object, enabling REPL recompilation without accumulating duplicates.
Names are symbols after macro normalization; lookup uses symbol identity, so
package identity matters. A test and a parent are distinct kinds of node.

Calling the installed function runs the body directly; `eval-test` is the boundary
that stores a result. Finding/removing nodes and clearing the root operate on the
registry, not on previously installed function definitions.

## Evaluation and results

An enabled `simple-test` uses a returned `test-result` as-is; an ordinary return
value, including `nil`, is success. A caught `error` becomes a result with status
`:error` and the condition as its description. `test-done` supplies an explicit
result and can interrupt a test early. Warnings alone are not failures: the
implementation catches errors, despite docstrings' broader wording about
"conditions."

The result is stored before an enabled test's non-`:ok` status raises a continuable
`test-error`. The runner invokes `continue` automatically unless
`:signal-condition-on-error?` is true. A disabled test does not call its body and
gets `:ignored` with zero duration. Classification defaults to `:ok` as passed,
`:ignored` as ignored, and everything else as failed; custom classes/statuses can
specialize the protocol. Durations are internal real-time ticks, not seconds.

## Traversal and orchestration

`test` defaults to an ANSI reporter and parallel traversal; `test-simple` uses a
plain reporter and serial traversal. Both continue after test failures by default.
Each parent start precedes its direct tests and child parents; its end follows
them. Each test has start, evaluation, and end callbacks. Reporter callbacks thread
an opaque context through the run; combined reporters keep one context per
delegate. Custom evaluation must leave a non-null result.

Serial traversal partitions direct tests from child parents, visiting tests first.
The default sequencer orders each list by declaration, with reverse and random
policies available. Its public reader/writer is `test-sequencer-ordering`, matching
the implemented accessor; the `:ordering` initarg configures its initial value.
Changing the accessor affects both `sequence-tests` and `sequence-parents`. The
unimplemented spelling `test-sequence-ordering` is not part of the public API.
The current recursive traversal does not forward a custom sequencer into nested
parents, so its selection/order is not applied recursively.

Parallel traversal runs a parent's direct tests sequentially on its worker while
traversing child parents, then joins the worker before the parent ends. Worker
errors are re-signaled after joining. Framework formatting/diff/time special
bindings are explicitly copied to workers; arbitrary caller bindings are not
promised to propagate. The concurrency rationale is owned by
`lustre-tests-architecture`.

Parent `test-passed?`/`test-failed?` query descendants and treat ignored tests as
non-failures. The stored parent result is not equivalent: in serial execution,
the runner marks it from direct callbacks only, treats ignored direct tests as
non-passing, and does not propagate nested failures into that stored status.
Do not assume that status is a recursive summary; the test harness uses the
descendant-query predicate.

## Assertions and reporting

`expect-seq` delegates equality/diff computation to `edit-distance`, using an
optional element predicate. Equality returns true; a mismatch raises continuable
`test-done` with a failed result and a diagnostic around the first mismatch.
Display limits bound the rendered diff, not diff computation. Control characters
are escaped visibly; plain output marks substitutions/insertions/deletions, while
colored output highlights them. The diagnostic Gray stream reports its own
visible-character column, excluding ANSI escapes, rather than assuming built-in
string streams implement Gray-stream column queries. Diff coloring is controlled
independently of a reporter's ANSI setting.

Plain and ANSI reporters count passed/ignored/failed tests, show durations, and
support `:full`, `:parents`, and `:quiet` modes. Failures remain visible in all
modes. Counts live on reporter instances and are not reset at run start; fresh
instances provide per-run totals. The README explicitly warns that built-in
reporters do not synchronize parallel output; deterministic, non-overlapping
reports are not guaranteed.

The Open Test Reporting reporter emits started/finished events in the event XML
format with unique atomic IDs and parent relationships. Results map to
`SUCCESSFUL`, `SKIPPED`, or `FAILED`; failure reasons are XML-escaped. An explicit
reporter stream overrides the runner stream. Header/footer suppression lets a
caller enclose additional events in the same document. Combining reporters does
not add synchronization or alter their semantics.

## Acknowledged limitations

The maintainer confirmed these as current gaps, not intended behavior:

- XML event names are inserted into attributes without escaping, unlike failure
  reasons. Names containing XML metacharacters can invalidate the document.
- The sequencer docstring says disabled tests are not run, but the implementation
  includes them in traversal and lets evaluation report them as ignored.

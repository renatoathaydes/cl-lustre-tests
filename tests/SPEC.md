---
id: lustre-tests-tests
type: module-design
status: active
title: Framework verification harness
parent: lustre-tests-architecture
depends-on: [lustre-tests-core, lustre-tests-color-sexp, lustre-tests-time]
tags: [testing]
---

# Framework verification harness

## Responsibility and boundary

The ASDF system `cl-lustre-tests/tests` verifies the production framework and its
formatting helpers. It is development tooling, never a production dependency.
The dependency edges are owned by `lustre-tests-architecture`; implementation
coverage and portability intent are owned by `lustre-tests-goals`.

## Two testing layers

Formatting-helper tests use Lustre Tests itself, exercising the public definition
and assertion workflow. Core framework tests instead use a deliberately tiny
function registry (`basic-test-framework`); the README explains that this is more
convenient than self-testing the core with itself. It does not provide an
independent implementation of every assertion: those tests still use
`expect-seq` for many output comparisons.

Framework tests isolate the dynamically bound root, construct synthetic results,
and temporarily replace time formatters to compare deterministic reports. These
intentional internal accesses do not make the referenced internals public API.
Clock replacement mutates global function bindings, so the affected tests must
not overlap.

CLISP-specific regressions verify serial fallback for both public test entry
points and direct parallel traversal, including caller dynamic bindings and
callback ordering. Reporter checks use the implementation-neutral event-ID
helpers so the same XML assertions apply to threaded and serial execution.

## Runner and reporting contract

`asdf:test-op` invokes `lustre-tests/runner:run-tests`. The runner first runs
registered helper tests with combined terminal and XML reporting, then runs the
basic-framework functions. A helper failure aborts the second stage; basic-test
errors are caught per test so remaining functions can run.

Both layers emit events into `unit-tests.xml`. The Open Test Reporting reporter
leaves the footer to the runner so non-Lustre tests can be appended to the same
document. The runner closes the file before quitting on its explicit early-failure
path. It uses the recursive failure predicate, not the stored parent status (see
`lustre-tests-core`).

`build.sh` and `test.sh` share a launcher selected by `LISP_IMPL` (default SBCL).
The launcher uses native batch/error-exit flags for SBCL, ABCL, CLISP, and ECL,
skips personal initialization, and loads the project's `init.lisp` explicitly so
user startup configuration cannot pre-load incompatible dependencies. When an
implementation cannot require ASDF, initialization loads OCICL's installed ASDF
copy; missing copies preserve the original startup error. CLISP uses `-i` for
startup files and `-x` for the ASDF operation, with `-on-error exit`. Other
implementations load startup files through evaluated forms: ABCL's `--load` can
enter its debugger and return success on EOF even in batch mode, whereas
`--eval` exits unsuccessfully
on an unhandled condition. The launcher exits after the ASDF operation rather
than entering a REPL. `test.sh` preserves the Lisp process exit status and optionally invokes an external HTML converter. Either a
helper failure or a final basic-framework failure supplies `1` to the runner's
report wrapper, which calls `uiop:quit` only after closing the report.

Each CI job checks that a deliberate startup-file error exits nonzero using a
small inline workflow step after OCICL setup, using the real project initializer
with an error appended. The matrix's real builds and Lisp tests verify each
implementation; no separate shell-test suite or mock executables are maintained.

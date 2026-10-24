---
id: lustre-tests-architecture
type: architecture-design
status: active
title: CL-Lustre-Tests architecture
parent: lustre-tests-goals
tags: [architecture]
---

# Architecture

## System boundary

CL-Lustre-Tests is an in-process Common Lisp library, distributed as the ASDF
system `cl-lustre-tests`. It registers and evaluates Lisp tests in the calling
image; reports go to caller-supplied streams. It does not own an external test
service or a separate execution process.

`lustre-tests-goals` owns product scope.

## Modules and dependency direction

The public `lustre-tests` package owns the CLOS protocol, registration, hierarchy,
execution, assertions, and reporters (`lustre-tests-core`, at `src/SPEC.md`).
Those are cooperating parts of one package, not separately loadable plugins.

Two subordinate packages provide presentation support: `lustre-tests-color-sexp`
formats Lisp forms, and `lustre-tests-time` formats durations and timestamps.
The core consumes both; neither helper imports the core or the other helper.
Their ASDF components load before the core component. They remain part of the
same distributed system, not independent ASDF systems.

The separate ASDF test system (`lustre-tests-tests`, at `tests/SPEC.md`) depends on
the production system and exercises the core and both helpers. Production code
has no dependency on the test harness. This is the dependency direction, not a
claim that tests use only exported symbols: framework tests deliberately reach
internals to isolate roots, clocks, and event IDs.

## Extension and execution model

The CLOS protocol separates evaluation, ordering, result classification, and
reporting so consumers can replace these policies without rewriting the runner.
The runner orchestrates callbacks and retains results; reporters consume those
results rather than deciding what executes. Sequencers return selections/orders
of existing tests or parents and must not create tests.

Concurrency is parent-scoped, not a pool of independently scheduled tests. The
maintainer confirmed the rationale: direct tests within one group remain
sequential, while different groups can overlap. This does not guarantee isolation
of tests' application state. Execution and reporting caveats belong to
`lustre-tests-core`.

## External boundaries

Bordeaux Threads supplies worker threads and atomic event IDs; Alexandria supplies
small utilities and shuffling. `edit-distance` computes sequence diffs,
`trivial-gray-streams` supports diagnostic output streams, and `format-ansi`
supplies color escapes. No runtime helper depends on the test harness.

Open Test Reporting XML is the machine-readable reporting boundary. Optional HTML
conversion is an external Java CLI step in `test.sh`, not a production-library
capability or runtime dependency. ASDF is the library integration point; the shell
scripts and OCICL setup are this repository's build/test tooling.

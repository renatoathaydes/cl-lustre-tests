---
id: lustre-tests-time
type: submodule-design
status: active
title: Duration and timestamp formatting
parent: lustre-tests-core
tags: [formatting]
---

# Duration and timestamp formatting

## Responsibility and boundary

The `lustre-tests/time` package turns numeric clock inputs into report text. It
does not measure test execution, schedule tests, or depend on test objects. The
caller supplies durations or timestamp inputs and owns their meaning; dependency
direction is recorded in `lustre-tests-architecture`.

## Duration contract

`print-time` accepts internal real-time ticks and prints nonzero components from
hours through microseconds, separated by commas; zero prints `0sec`. It returns
`nil`, so callers needing a string capture the stream rather than use the return
value. The conversion scale defaults to `internal-time-units-per-second` and is
dynamically bindable for tests and callers.

Precision is limited by that scale. A zero divisor for a subsecond unit yields
zero rather than a division error, allowing millisecond-resolution implementations
to omit microseconds. Tests explicitly cover millisecond and microsecond scales.

## Timestamp contract

`print-timestamp` combines decoded universal time with the subsecond portion of
an internal real-time input, emitting a date/time string with six fractional
digits and a `Z` suffix. Those two clocks are supplied independently: the suffix
and displayed precision do not establish clock synchronization or accuracy.
There are currently no direct timestamp tests; the reporter tests replace the
formatter to make event output deterministic.

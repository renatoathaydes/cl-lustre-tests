---
id: lustre-tests-color-sexp
type: submodule-design
status: active
title: S-expression diagnostic formatting
parent: lustre-tests-core
tags: [formatting]
---

# S-expression diagnostic formatting

## Responsibility and boundary

The `lustre-tests/color-sexp` package prints Lisp forms with token-category colors
and readable line breaking, for failure diagnostics. It accepts a stream or
returns a string; it neither evaluates forms nor knows about test objects or
reporter lifecycles. Package independence is described in
`lustre-tests-architecture`.

This is a reusable diagnostic presentation helper, not a general Lisp
pretty-printer.

## Formatting contract

Lists use parentheses and non-string sequences handled as nested arrays use
brackets; strings remain atoms. Symbol rendering uses the supplied package
context, avoiding qualification for its own symbols. Token categories distinguish
strings, characters, numbers, keywords, symbols, special operators, selected
macros, and ampersand-prefixed symbols. Each category has a dynamically bindable
color override with a default palette.

The line limit defaults to 96 visible characters; `nil` disables wrapping. Width
accounting excludes ANSI escapes, and nested terms that do not fit move to an
indented line where possible. This is a best-effort layout: indivisible atoms can
exceed the limit. It is diagnostic output, not a guaranteed read/print round trip.

`color-sexp` returns `nil`; `color-sexp-to-string` captures the same rendering.
Color emission uses `format-ansi`. Adding dynamically bound formatting controls
also requires updating the worker-binding integration owned by
`lustre-tests-core`.

# Changelog

## [0.2.0]

### Fixed

- Export the implemented `test-sequencer-ordering` accessor instead of the
  nonexistent `test-sequence-ordering` symbol, allowing callers to read and change
  a sequencer's ordering through the public API.
- Fix `expect-seq` mismatch diagnostics by reporting the diagnostic stream's own
  visible-character column, excluding ANSI escape sequences, instead of querying
  the underlying string stream. This avoids Gray stream compatibility errors on
  ABCL and ECL.

## [0.1.0]

- Initial release.

[0.2.0]: https://github.com/renatoathaydes/cl-lustre-tests/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/renatoathaydes/cl-lustre-tests/releases/tag/0.1.0

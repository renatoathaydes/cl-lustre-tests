# CL-Lustre-Tests

**Common Lisp - Lustre Tests** is a powerful testing framework that focuses on usability and great reporting.

The design of this library is based on a simple CLOS [protocol](src/protocol.lisp) that makes it easy to extend.
For most users, however, things should work out-of-the-box without requiring any understanding of it at all.

## Getting Started

Add a dependency to the `cl-lustre-tests` system to your `.asd` file:

```lisp
  :depends-on  ("cl-lustre-tests")
```

Also, configure your `asdf:test-op` to invoke the `test` function from this system:

```lisp
  :perform (asdf:test-op (op c)
                         (uiop:symbol-call :lustre-tests/test))
```

The main package is `lustre-tests`, which is a bit long, so add a nickname in your package declaration:

```lisp
(defpackage your-package
  (:use #:cl)
  (:local-nicknames (#:lt #:lustre-tests)))
```

Or in the REPL:

```lisp
CL-USER> (add-package-local-nickname :lt :lustre-tests)
```

Write a test:

```lisp
(lt:define-test my-first-test ()
    (assert (= (+ 2 2) 4)))
```

Now, you can execute the test with ASDF:

```lisp
(asdf:test-system :your-system)
```

Or in the REPL:

```lisp
CL-USER> (lt:test-simple)
```

> The `test-simple` function uses a `simple-test-reporter` instead of `ansi-test-reporter`,
  which is more appropriate on the terminal as it prints colorful reports via ANSI color codes,
  and is the default used by the `test` function.
  You can enable ANSI colors on SLIME, if you want, by using the [slime-repl-ansi-color](https://gitlab.com/renatoathaydes/slime-repl-ansi-color/-/tree/master) mode, so colors work also on emacs!

## Writing Tests

A Lustre Test is a function which gets wrapped into an instance of `LT:SIMPLE-TEST` by default. `lt:define-test` makes an instance of that
class and add the test name to the ROOT parent (accessible via `lt:init-root)`).

If the function returns an instance of `LT:TEST-RESULT`, that's used, otherwise it's assumed that that does not signal any conditions
passed. Hence, you should use assertions such as:

* `assert` (CL default assertions, enough for most cases as errors show the values in an expression).
* `check-type` (also from CL, can be useful to verify types).
* `lt:expect-seq` compares two sequences' elements and on failure, prints a pretty diff (using colors if enabled).

Example test:

```lisp
(lt:define-test mapcar+1-works ()
    (lt:expect-seq '(2 3 4) (mapcar #'1+ '(1 2 3))))
```

> Recompiling the test replaces it just like a normal function. This allows fixing tests in the REPL by re-compiling the test
  or the implementation and immediately using the `RETRY` restart.

For more realistic examples, look at Lustre-Tests' own supporting packages tests:

* [color-sexp tests](tests/color-sexp-tests/package.lisp)
* [print-time tests](tests/time-tests/package.lisp)

> The core functionality is tested with a separate, basic-test-framework, as that's more convenient than trying to self-test.

## Grouping tests

Each test definition may declare a test's parents. In the following example, we declare a test `FOO` under parents `P1 -> P2`:

```lisp
(lt:define-test FOO (P1 P2)
    (assert T))
```

Parent names don't need to be predefined. To check your test hiearchy, you can use `LT:PRINT-TEST-TREE`:

```lisp
CL-USER> (lt:print-test-tree (init-root))
```

Which, for the example above, prints:

```
* ROOT
  * P1
    * P2
      - FOO
```


TODO

## Author and License

`cl-lustre-tests` was written by Renato Athaydes and is distributed
under the terms of the MIT license.

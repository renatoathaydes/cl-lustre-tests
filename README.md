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

If the function returns an instance of `LT:TEST-RESULT`, that's used as the actual result for the test,
otherwise it's assumed that, as the test did not signal any conditions, it must have passed.

Hence, one should always use assertions in tests such as:

* `assert` (CL default assertions, enough for most cases as errors show the values in an expression).
* `check-type` (also from CL, can be useful to verify types).
* `lt:expect-seq` compares two sequences' elements and on failure, prints a pretty diff (using colors if enabled).

More information about `expect-seq` in the [Assertions](#assertions) section below.

Example tests:

```lisp
(lt:define-test "2 + 2 should eq 4" ()
    (assert (= (+ 2 2) 4)))

(lt:define-test mapcar+1-works ()
    (lt:expect-seq '(2 3 4) (mapcar #'1+ '(1 2 3))))
```

> Recompiling the test replaces it just like a normal function. This allows fixing tests in the REPL by re-compiling the test
  or the implementation and immediately using the `RETRY` restart.

For more realistic examples, look at Lustre-Tests' own supporting packages tests:

* [color-sexp tests](tests/color-sexp-tests/package.lisp)
* [print-time tests](tests/time-tests/package.lisp)

> The core functionality of this library is tested with a separate, basic-test-framework, as that's more convenient than trying to self-test.

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

### Test Parallelization

Besides being useful for test organization, using test parents also enables parallelization:
calling the `test` functions with `:parallel T` causes each TEST-PARENT to run its children on a separate Thread.

> Warning: when using this option, use a TEST-REPORTER that can handle multi-threading.
  The default implementations may print overlapping results as they do not synchronize.

<div id="assertions" />

## Assertions

In many cases, Common Lisp's default assertions are good enough for testing.
For example, `assert` shows a nice message when it fails that includes runtime values from the assertion:

```lisp
CL-USER> (defparameter x 5)
X
CL-USER> (lt:define-test arithmetics-work? ()
           (assert (= (+ 2  x) 5)))
NIL
CL-USER> (lt:test-simple)
== LUSTRE TESTS ==

Running 1 test(s).
ERROR: COMMON-LISP-USER::ARITHMETICS-WORK?
(PROGN (ASSERT (= (+ 2 X) 5))) =>
    The assertion (= (+ 2 X) 5) failed with (+ 2 X) = 7.
Success: 0, Failures: 0, Errors: 1
NIL
```

It can be clearly seen that the expression that failed the assertion evaluated to `7`, not the expected `5`.

For this reason, Lustre Tests only provides a single assertion, `lt:expect-seq`, that gives a lot of value when compared to that.
That's especially true when comparing large sequences (including strings) which can differ in subtle, hard to see ways.

TODO add `expect-seq` examples with colors.

## Debugging tests

While working on tests, you can use the REPL very conveniently.
Call the test function with `:signal-condition-on-error? T` so that the debugger is called on each test failure,
which you can then try to fix and then restart with `RETRY`.

```lisp
CL-USER> (lt:test-simple :signal-condition-on-error? T)
```

You can also use `find-test` to run only tests under a specific TEST-PARENT:

```lisp
CL-USER> (lt:find-test 'my-test-parent (lt:init-root))
```

If you store the TEST-PARENT in a variable `P` for example, run it with:

```lisp
CL-USER> (lt:test-simple :test-parent p :signal-condition-on-error? T)
```

For each test that fails, the debugger will stop with the following restarts:

```lisp
Test LUSTRE-TESTS/TIME/TESTS::PRINT-TIME-WITH-ALL-UNITS failed.
The assertion
(STRING= "18hr, 45mn, 1sec, 234ms, 567µs"
         (LUSTRE-TESTS/TIME/TESTS::PRINT-TIME-TO-STRING
          (+ (* 18 60 60 1000000) (* 45 60 1000000) 1234567)))
failed with
(LUSTRE-TESTS/TIME/TESTS::PRINT-TIME-TO-STRING
 (+ (* 18 60 60 1000000) (* 45 60 1000000) 1234567))
= "18hr, 45min, 1sec, 234ms, 567µs".
   [Condition of type LT:TEST-ERROR]

Restarts:
 0: [CONTINUE] Ignore test failure.
 1: [RETRY] Retry SLIME REPL evaluation request.
 2: [*ABORT] Return to SLIME's top level.
 3: [ABORT] Exit debugger, returning to top level.
```

Try to fix the cause of the error, recompile the function in SLIME then hit `1` to invoke `RETRY`.
To continue to the next test anyway, use the `CONTINUE` restart (the test still shows as having failed in the report).

## Finding tests

As mentioned in the previous section, you can find a test with `lt:find-test`:

```lisp
CL-USER> (lt:find-test 'my-test-parent (lt:init-root))
```

The `lt:find-test` function, as the `lt:define-test` macro, allows declaring the test parents as well, so to find a test
called `FOO` under the `P1 -> P2` parents, use:

```lisp
CL-USER> (lt:find-test 'foo (lt:init-root) '(p1 p2))
```

> Notice that you may need to use the fully qualified symbol to find a test if you're not in the same package.

The `lt:find-test` finds both `TEST-PARENT` and `TEST-OBJECT` (runnable tests).
Once you have a test parent, you can then find more tests under it again, so you could do this as well:

```lisp
CL-USER> (lt:find-test 'p1 (lt:init-root))
#<LT:TEST-PARENT {800961E3D3}>
CL-USER> (lt:find-test 'p2 *)
#<LT:TEST-PARENT {800961F8F3}>
CL-USER> (lt:find-test 'foo *)
#<LT:SIMPLE-TEST {80065F75B3}>
```

## Running tests

The previous sections already showed you can run all children of a test parent with one of the `test` functions:

```lisp
CL-USER> (defparameter p (lt:find-test 'p1 (lt:init-root)))
P
CL-USER> (lt:test :test-parent p)
```

The default test root, given by `(lt:init-root)`, is the default value for the `:test-parent` parameter,
so to run all tests, just omit it:

```lisp
CL-USER> (lt:test)
```

To run a single `TEST-OBJECT` (usually of type `SIMPLE-TEST`), just run the function with the name of the test.

> `lt:define-test` creates a test with the given name, but also a function with the same name. Hence, running the test
  is as easy as running a function.

If you want the `test-result` to be set, then you need to use the `lt:eval-test` method:

```lisp
CL-USER> (setvar test (lt:find-test 'foo (lt:init-root) '(p1 p2)))
TEST
CL-USER> (lt:eval-test test)
#<LT:SIMPLE-TEST {8009613F63}>
```

If the test passes, it's simply returned. On failure, a CONDITION is signalled so you'll enter the debugger.

The test result is set on the `TEST-OBJECT` either way. You can print it as follows:

```lisp
CL-USER> (lt:test-result test)
```

### Test functions

The `lt:test` function is the preferred function for running tests on a CI server or the terminal. It uses
appropriate defaults for that:

* the `ansi-test-reporter`, which prints results in colors using ANSI codes.
* it does not signal conditions on test failures, so all tests run to completion even if previous tests failed.
* each `TEST-PARENT` runs its children on a separate Thread.
* tests run in declaration order.

The `lt:test-simple` function is better for the REPL. The differences from `lt:test` are:

* it uses `simple-test-reporter` (no ANSI colors).
* conditions are signalled on test failures, allowing fixing or skipping them live.
* tests are not run in parallel.

## Deleting tests

It's possible to remove a single `TEST-OBJECT` or `TEST-PARENT` with `lt:remove-test`
(which has the same signature as `lt:find-test`):

```lisp
CL-USER> (lt:remove-test 'foo (lt:init-root) '(p1 p2))
T
```

You can clear all tests as follows:

```lisp
CL-USER> (lt:clear-tests)
NIL
CL-USER> (lt:print-test-tree (lt:init-root))
* ROOT
```

## Author and License

`cl-lustre-tests` was written by Renato Athaydes and is distributed
under the terms of the MIT license.

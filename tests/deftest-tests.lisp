(in-package #:lustre-tests/tests)

(define-lustre-test deftest-defines-test-globally-by-default ()
  (let ((lustre-tests::*tests* nil))
    (lustre-tests:deftest my-test () T)
    (assert (= 1 (length lustre-tests::*tests*)))))

(define-lustre-test deftest-can-define-test-locally ()
  (let ((local-tests nil))
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length local-tests)))
    (assert (= 0 (length lustre-tests::*tests*)))))

(define-lustre-test deftest-can-redefine-test-locally ()
  (let ((local-tests nil))
    (lustre-tests:deftest my-test (local-tests) T)
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length local-tests)))
    (assert (= 0 (length lustre-tests::*tests*)))))

(in-package #:lustre-tests/tests)

(defun run-tests ()
  (format T "Running Lustre Tests' own tests!~%")
  (deftest-defines-test-globally-by-default)
  (deftest-can-define-test-locally)
  (format T "Success!~%"))

(defun deftest-defines-test-globally-by-default ()
  (let ((lustre-tests::*tests* nil))
    (lustre-tests:deftest my-test () T)
    (assert (= 1 (length lustre-tests::*tests*)))))

(defun deftest-can-define-test-locally ()
  (let ((local-tests nil))
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length local-tests)))
    (assert (= 0 (length lustre-tests::*tests*)))))

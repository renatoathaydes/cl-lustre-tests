(in-package #:lustre-tests/tests)

(define-lustre-test deftest-defines-test-globally-by-default ()
  (let ((lustre-tests:*root-test-parent* (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:deftest my-test () T)
    (assert (= 1 (length (lustre-tests:test-children lustre-tests:*root-test-parent*))))))

(define-lustre-test deftest-can-define-test-locally ()
  (let ((local-tests (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length (lustre-tests:test-children local-tests))))
    (assert (= 0 (length (lustre-tests:test-children lustre-tests:*root-test-parent*))))))

(define-lustre-test deftest-can-redefine-test-locally ()
  (let ((local-tests (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:deftest my-test (local-tests) T)
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length (lustre-tests:test-children local-tests))))
    (assert (= 0 (length (lustre-tests:test-children lustre-tests:*root-test-parent*))))))

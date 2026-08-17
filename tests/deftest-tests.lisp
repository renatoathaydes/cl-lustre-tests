(in-package #:lustre-tests/tests)

(define-lustre-test define-test-defines-test-globally-by-default ()
  (let ((lustre-tests:*root-test-parent* (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:define-test my-test () T)
    (assert (= 1 (length (lustre-tests:test-children lustre-tests:*root-test-parent*))))))

(define-lustre-test define-test-can-define-test-locally ()
  (let ((local-tests (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:define-test my-test (local-tests) T)
    (assert (= 1 (length (lustre-tests:test-children local-tests))))
    (assert (= 0 (length (lustre-tests:test-children lustre-tests:*root-test-parent*))))))

(define-lustre-test define-test-can-redefine-test-locally ()
  (let ((local-tests (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:define-test my-test (local-tests) T)
    (lustre-tests:define-test my-test (local-tests) T)
    (assert (= 1 (length (lustre-tests:test-children local-tests))))
    (assert (= 0 (length (lustre-tests:test-children lustre-tests:*root-test-parent*))))))

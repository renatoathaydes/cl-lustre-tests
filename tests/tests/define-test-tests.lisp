(in-package #:lustre-tests/tests)

(define-lustre-test define-test-defines-test-no-parents ()
  (with-local-root (root)
    (lustre-tests:define-test my-test () T)
    (assert (= 1 (length (lustre-tests:test-children root))))))

(define-lustre-test define-test-defines-test-under-parent ()
  (with-local-root (root)
    (lustre-tests:define-test my-test (local-tests) T)
    (let ((parent (lustre-tests:find-child 'local-tests root)))
      (assert (typep parent 'lustre-tests:test-parent))
      (assert (= 1 (length (lustre-tests:test-children parent))))
      (assert (= 1 (length (lustre-tests:test-children root)))))))

(define-lustre-test define-test-can-redefine-test ()
  (with-local-root (root)
    (lustre-tests:define-test my-test (local-tests) :FIRST)
    (lustre-tests:define-test my-test (local-tests) :SECOND)
    (let ((parent (lustre-tests:find-child 'local-tests root)))
      (assert (typep parent 'lustre-tests:test-parent))
      (assert (= 1 (length (lustre-tests:test-children parent))))
      (assert (= 1 (length (lustre-tests:test-children root))))
      ;; the latest test defined wins
      (assert (eql (funcall
                    (lustre-tests::test-fun
                     (lustre-tests:find-child 'my-test parent)))
                   :SECOND)))))

(in-package #:lustre-tests/tests)

(define-lustre-test define-test-defines-test-no-parents
  (with-local-root (root)
    (lt:define-test my-test () T)
    (assert (= 1 (length (lt:test-children root))))))

(define-lustre-test define-test-defines-test-under-parent
  (with-local-root (root)
    (lt:define-test my-test (local-tests) T)
    (let ((parent (lt:find-test 'local-tests root)))
      (assert (typep parent 'lt:test-parent))
      (assert (= 1 (length (lt:test-children parent))))
      (assert (= 1 (length (lt:test-children root)))))))

(define-lustre-test define-test-can-redefine-test
  (with-local-root (root)
    (lt:define-test my-test (local-tests) :FIRST)
    (lt:define-test my-test (local-tests) :SECOND)
    (let ((parent (lt:find-test 'local-tests root)))
      (assert (typep parent 'lt:test-parent))
      (assert (= 1 (length (lt:test-children parent))))
      (assert (= 1 (length (lt:test-children root))))
      ;; the latest test defined wins
      (assert (eql (funcall
                    (lt::test-fun
                     (lt:find-test 'my-test parent)))
                   :SECOND)))))

(in-package #:lustre-tests/tests)

(define-lustre-test define-test-defines-test-no-parents
  (with-local-root (root)
    (let ((test (lustre-tests:define-test my-test () T)))
      (assert-t (lustre-tests:test-enabled? test)))
    (assert (= 1 (length (lustre-tests:test-children root))))))

(define-lustre-test define-test-defines-test-under-parent
  (with-local-root (root)
    (lustre-tests:define-test my-test (local-tests) T)
    (let ((parent (lustre-tests:find-test 'local-tests root)))
      (assert (typep parent 'lustre-tests:test-parent))
      (assert (= 1 (length (lustre-tests:test-children parent))))
      (assert (= 1 (length (lustre-tests:test-children root)))))))

(define-lustre-test define-test-can-redefine-test
  (with-local-root (root)
    (lustre-tests:define-test my-test (local-tests) :FIRST)
    (lustre-tests:define-test my-test (local-tests) :SECOND)
    (let ((parent (lustre-tests:find-test 'local-tests root)))
      (assert (typep parent 'lustre-tests:test-parent))
      (assert (= 1 (length (lustre-tests:test-children parent))))
      (assert (= 1 (length (lustre-tests:test-children root))))
      ;; the latest test defined wins
      (assert (eql (funcall
                    (lustre-tests::test-fun
                     (lustre-tests:find-test 'my-test parent)))
                   :SECOND)))))

(define-lustre-test define-test!-disabled-test
  (with-local-root (root)
    (lustre-tests:define-test! disabled-test () ('lustre-tests:simple-test :enabled nil) T)
    (let ((test (lustre-tests:find-test 'disabled-test root)))
      (assert (typep test 'lustre-tests:simple-test))
      (assert-nil (lustre-tests:test-enabled? test)))))

(defclass custom-test (lustre-tests:simple-test)
  ((great-test? :initarg :great :reader test-great?)))

(define-lustre-test define-test!-custom-class
  (with-local-root (root)
    (declare (ignore root))
    (let ((test (lustre-tests:define-test! great-test () ('custom-test :great T) T)))
      (assert (typep test 'custom-test))
      (assert-t (test-great? test)))))

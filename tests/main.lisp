(in-package #:lustre-tests/tests)

;;;; Tiniest test framework in the world ;;;;

(defparameter *tests* nil)

(defmacro define-lustre-test (name &body body)
  `(progn
     (defun ,name () ,@body)
     (pushnew ',name *tests*)))

;;;; ACTUAL TESTS ;;;;

(define-lustre-test deftest-defines-test-globally-by-default ()
  (let ((lustre-tests::*tests* nil))
    (lustre-tests:deftest my-test () T)
    (assert (= 1 (length lustre-tests::*tests*)))))

(define-lustre-test deftest-can-define-test-locally ()
  (let ((local-tests nil))
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length local-tests)))
    (assert (= 0 (length lustre-tests::*tests*)))))

;;;; TEST RUNNER ;;;;

(defmacro run-test (name)
  `(handler-case (progn
                    (funcall ,name)
                    (incf success-count))
     (error (e)
       (incf error-count)
       (format T "ERROR: ~A~%  ~A~%" ',name e))))

(defun run-tests ()
  (format T "Running Lustre Tests' own tests!~%")
  (let ((error-count 0)
        (success-count 0))
    (dolist (test *tests*)
      (run-test test))
    (if (zerop error-count)
        (format T "SUCCESS - all ~A test(s) passed!~%" success-count)
        (format T "Not ok: ~A error(s), ~A OK.~%" error-count success-count))))

(defpackage lustre-tests/runner
  (:documentation "basic-framework test runner.")
  (:use #:cl #:lustre-tests/basic-framework)
  (:local-nicknames (#:lt #:lustre-tests))
  (:export #:run-tests))

(in-package #:lustre-tests/runner)

(defmacro run-test (name)
  `(handler-case (progn
                    (funcall ,name)
                    :ok)
     (error (e)
       (ansi:format-ansi T `(
                             (:fg :red "ERROR: ~A~%" ,(symbol-name ,name))
                             ("  ~A~%" ,e)))
       :failed)))

(defun run-tests ()
  (format T "==> Running Lustre Tests helper module tests!~%~%")
  (let ((reporter (make-instance 'lt:ansi-test-reporter :mode :full))
        (lt:*show-diff-with-ansi-colors* T))
    (lt:test :reporter reporter)
    (unless (zerop (slot-value reporter 'lt::fail-count))
      (uiop:quit 1)))
  (format T "~%==> Running Lustre Tests' own tests (using basic-test-framework)!~%~%")
  (let ((error-count 0)
        (success-count 0))
    (dolist (test *tests*)
      (let ((result (run-test test)))
        (ecase result
          (:ok (incf success-count))
          (:failed (incf error-count)))))
    (if (zerop error-count)
        (ansi:format-ansi T `((:fg :green "OK - all ~A test(s) passed!~%" ,success-count)))
        (flet ((print-results ()
                 (ansi:format-ansi T `((:fg :red "Not OK: ~A error(s), ~A OK.~%" ,error-count ,success-count)))))
          (print-results)
          (uiop:quit 1)))))

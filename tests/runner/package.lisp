(defpackage lustre-tests/runner
  (:documentation "basic-framework test runner.")
  (:use #:cl #:lustre-tests/basic-framework)
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

(defun run-tests (&key (on-error :condition))
  "Run the tests.
The ERROR-MODE should be one of :condition | :print | :exit."
  (format T "==> Running color-sexp module tests!~%~%")
  (flet ((run-lustre-tests ()
           (let ((lustre-tests:*show-diff-with-ansi-colors* T))
             (lustre-tests:test :signal-condition-on-error?
                                (not (eq on-error :print))))))
    (if (eq :condition on-error)
        (run-lustre-tests) ;; no handler in this case
        (handler-case
            (run-lustre-tests)
          (error (e)
            (declare (ignore e))
            (ecase on-error
              (:print nil) ;; the test-reporter already prints the error
              (:exit (uiop:quit 1)))))))
  (format T "==> Running Lustre Tests' own tests (using basic-test-framework)!~%~%")
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
          (ecase on-error
            (:condition (error 'lustre-tests:test-error
                               :reason `(:success-count ,success-count :error-count ,error-count)))
            (:print (print-results))
            (:exit (print-results)
             (uiop:quit 1)))))))

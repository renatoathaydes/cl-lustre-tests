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

(defmacro with-test-reporter ((reporter) &body action)
  (if nil
      `(with-open-file (stream #P"unit-tests.xml"
                               :direction :output
                               :if-exists :supersede)
         (let ((,reporter (make-instance 'lt:opentest-test-reporter :stream stream)))
           ,@action))
      `(let ((,reporter (make-instance 'lt:ansi-test-reporter :mode :full))
             (lt:*show-diff-with-ansi-colors* T))
         ,@action)))

(defun run-tests ()
  (format T "==> Running Lustre Tests helper module tests!~%~%")
  (with-test-reporter (reporter)
    (lt:test :reporter reporter))
  (when (lt:test-failed? (lt:init-root))
    (ansi:format-ansi T "Aborting due to Lustre Test failure(s)." :fg :red)
    (uiop:quit 1))
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


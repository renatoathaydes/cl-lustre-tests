(defpackage lustre-tests/runner
  (:documentation "basic-framework test runner.")
  (:use #:cl #:lustre-tests/basic-framework)
  (:export #:run-tests))

(in-package #:lustre-tests/runner)

(defun run-test (name parent-id stream)
  "Run non-Lustre-Test test by NAME.
   Sends Opentest XML events to STREAM."
  (let ((id (lustre-tests::next-event-id)))
    (lustre-tests::print-event-started id parent-id name stream)
    (handler-case
        (progn (funcall name)
               (lustre-tests::print-event-finished id "SUCCESSFUL" stream)
               T)
      (error (e)
        (lustre-tests::print-event-finished id "FAILED" stream e)
        (ansi:format-ansi T `(
                              (:fg :red "ERROR: ~A~%" ,(symbol-name name))
                              ("  ~A~%" ,e)))
        nil))))

(defmacro with-test-reporter ((reporter stream) &body action)
  "With an instance of TEST-REPORTER and a file STREAM, perform the given ACTION.
   ACTION may return an exit-code. Early return is supported."
  (let ((r1 (gensym))
        (r2 (gensym))
        (file-stream (gensym))
        (exit-code (gensym)))
    `(let ((,exit-code
             (with-open-file (,file-stream #P"unit-tests.xml"
                                           :direction :output
                                           :if-exists :supersede)
               (let* ((,r1 (make-instance 'lustre-tests:opentest-test-reporter
                                          :stream ,file-stream
                                          ;; we'll append non-lustre-tests results to the report
                                          :footer? nil))
                      (,r2 (make-instance 'lustre-tests:ansi-test-reporter :mode :full))
                      (,reporter (make-instance 'lustre-tests:combined-test-reporter
                                                :delegates (list ,r1 ,r2)))
                      (,stream ,file-stream)
                      (lustre-tests:*show-diff-with-ansi-colors* T))
                 (let ((result (block with-test-reporter ,@action)))
                   ;; since the reporter did not print the footer, we do it here
                   (write-string lustre-tests::+opentest-xml-footer+ ,file-stream)
                   result)))))
       (when ,exit-code (uiop:quit ,exit-code)))))

(defun run-tests ()
  (format T "==> Running Lustre Tests helper module tests!~%")
  (format T "    Time resolution is ~E/sec.~%" internal-time-units-per-second)
  (with-test-reporter (reporter stream)
    (lustre-tests:test :reporter reporter)
    (when (lustre-tests:test-failed? (lustre-tests:init-root))
      (ansi:format-ansi T "Aborting due to Lustre Test failure(s)." :fg :red)
      (return-from with-test-reporter 1))
    (format T "~%==> Running Lustre Tests' own tests (using basic-test-framework)!~%~%")
    (let ((root-id (lustre-tests::next-event-id))
          (error-count 0)
          (success-count 0)
          ;; these tests expect plain diffs, unlike the Lustre Tests run above
          (lustre-tests:*show-diff-with-ansi-colors* nil))
      (lustre-tests::print-event-started root-id nil :non-lustre-tests stream)
      (dolist (test *tests*)
        (let ((test-passed? (run-test test root-id stream)))
          (cond
            (test-passed?
             (incf success-count)
             (ansi:format-ansi T `((:fg :green "OK: ")
                                   ("~A~%" ,test))))
            (T
             (incf error-count)
             (ansi:format-ansi T `((:fg :red "FAILED: ")
                                   ("~A~%" ,test)))))))
      (cond
        ((zerop error-count)
         (ansi:format-ansi T `((:fg :green "OK - all ~A test(s) passed!~%" ,success-count)))
         (lustre-tests::print-event-finished root-id "SUCCESSFUL" stream)
         nil)
        (T
         (ansi:format-ansi T `((:fg :red "Not OK: ~A error(s), ~A OK.~%" ,error-count ,success-count)))
         (lustre-tests::print-event-finished root-id "FAILED" stream)
         1)))))

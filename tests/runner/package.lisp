(defpackage lustre-tests/runner
  (:documentation "basic-framework test runner.")
  (:use #:cl #:lustre-tests/basic-framework)
  (:local-nicknames (#:lt #:lustre-tests))
  (:export #:run-tests))

(in-package #:lustre-tests/runner)

(defun run-test (name parent-id stream)
  "Run non-Lustre-Test test by NAME.
   Sends Opentest XML events to STREAM."
  (let ((id (bt2:atomic-integer-incf lt::*id-counter*)))
    (lt::print-event-started id parent-id name stream)
    (handler-case
        (progn (funcall name)
               (lt::print-event-finished id "SUCCESSFUL" stream)
               T)
      (error (e)
        (lt::print-event-finished id "FAILED" stream e)
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
               (let* ((,r1 (make-instance 'lt:opentest-test-reporter
                                          :stream ,file-stream
                                          ;; we'll append non-lustre-tests results to the report
                                          :footer? nil))
                      (,r2 (make-instance 'lt:ansi-test-reporter :mode :full))
                      (,reporter (make-instance 'lt:combined-test-reporter
                                                :delegates (list ,r1 ,r2)))
                      (,stream ,file-stream)
                      (lt:*show-diff-with-ansi-colors* T))
                 (let ((result (block with-test-reporter ,@action)))
                   ;; since the reporter did not print the footer, we do it here
                   (write-string lt::+opentest-xml-footer+ ,file-stream)
                   result)))))
       (when ,exit-code (uiop:quit ,exit-code)))))

(defun run-tests ()
  (format T "==> Running Lustre Tests helper module tests!~%")
  (format T "    Time resolution is ~E/sec.~%" internal-time-units-per-second)
  (with-test-reporter (reporter stream)
    (lt:test :reporter reporter)
    (when (lt:test-failed? (lt:init-root))
      (ansi:format-ansi T "Aborting due to Lustre Test failure(s)." :fg :red)
      (return-from with-test-reporter 1))
    (format T "~%==> Running Lustre Tests' own tests (using basic-test-framework)!~%~%")
    (let ((root-id (bt2:atomic-integer-incf lt::*id-counter*))
          (error-count 0)
          (success-count 0)
          ;; these tests expect plain diffs, unlike the Lustre Tests run above
          (lt:*show-diff-with-ansi-colors* nil))
      (lt::print-event-started root-id nil :non-lustre-tests stream)
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
         (lt::print-event-finished root-id "SUCCESSFUL" stream)
         nil)
        (T
         (ansi:format-ansi T `((:fg :red "Not OK: ~A error(s), ~A OK.~%" ,error-count ,success-count)))
         (lt::print-event-finished root-id "FAILED" stream)
         1)))))

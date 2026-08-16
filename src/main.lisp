(in-package #:lustre-tests)

(defparameter *tests* nil
  "List of TEST-OBJECTs. Execute all tests by invoking TEST.")

(defmacro deftest (name (&optional parent) &body body)
  "Add a test to the framework.
If the parent is given, the test is PUSHed into it instead of *TESTS*.
The body should return NIL to pass. Use an assertion macro to set up proper error messages."
  (let ((test-container (or parent '*tests*))
        (test-name (if (symbolp name) (symbol-name name) name)))
    `(push (make-instance 'simple-test :name ,test-name :body '(progn ,@body)) ,test-container)))

(defun test (&key
               (tests *tests*)
               (stream *standard-output*)
               (sequencer (make-instance 'simple-test-sequencer))
               (reporter (make-instance 'ansi-test-reporter))
               (signal-condition-on-error? nil))
  "Run all tests.
The test protocol is as follows:
  - report-start
  - sequence-tests
  - eval-test (for each test)
  - report-result (for each test)
  - report-end
If SIGNAL-CONDITION-ON-ERROR? is not NIL, a TEST-ERROR is signalled on each test failure or error."
  (report-start stream reporter tests)
  (dolist (test (sequence-tests sequencer tests)) ;; TODO handle test-parent
    (eval-test test)
    (let ((result (test-result test)))
      (when (null result)
        (error "Test ~A has no result after being run." test))
      (when (and signal-condition-on-error?
                 (not (eq :ok (test-result-status result))))
        (error 'test-error :reason (test-result-description result))))
    (report-result stream reporter test))
  (report-end stream reporter tests))

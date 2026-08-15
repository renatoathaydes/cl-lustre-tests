(in-package #:lustre-tests)

(defparameter *tests* nil
  "List of TEST-OBJECTs. Execute all tests by invoking TEST.")

(defmacro deftest (name (&optional parent) &body body)
  "Add a test to the framework.
If the parent is given, the test is PUSHed into it instead of *TESTS*.
The body should return NIL to pass. Use an assertion macro to set up proper error messages."
  (let ((test-container (or parent '*tests*)))
    `(push (make-instance 'simple-test :name ,name :body '(progn ,@body)) ,test-container)))

(defun test (&key
               (tests *tests*)
               (stream *standard-output*)
               (sequencer (make-instance 'simple-test-sequencer))
               (reporter (make-instance 'ansi-test-reporter)))
  "Run all tests."
  (report-start stream reporter tests)
  (dolist (test (sequence-tests sequencer tests)) ;; TODO handle test-parent
    (report-result stream reporter (eval-test test)))
  (report-end stream reporter tests))

(in-package #:lustre-tests)

(defparameter *root-test-parent* nil
  "The root of the test hierarchy. Execute all tests by invoking TEST.")

(defun init-root ()
  (if *root-test-parent*
      *root-test-parent*
      (setf *root-test-parent* (make-instance 'test-parent :name 'ROOT))))

(defun make-test-name (name)
  "Convert the name to a SYMBOL."
  (typecase name
    (string (intern name))
    (symbol name)
    (number (intern (format nil "~D" name)))
    (otherwise (error "Name must be string | symbol | number."))))

(defmacro define-test (name (&rest parents) &body body)
  "Add a test to the framework.
If PARENTS are given, the test location matching the names of the parents is found or created.
The body should return NIL to pass. Use an assertion macro to set up proper error messages."
  (let ((test-name (gensym)))
    `(let ((,test-name (make-test-name ',name)))
       (add-test
        (make-instance 'simple-test :name ,test-name :body (lambda () ,@body))
        (init-root)
        (mapcar #'make-test-name ',parents)))))

(defun test (&key
               (test-parent (init-root))
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
  (let ((ctx nil))
    (flet ((on-start-parent (p)
             (setf ctx (report-start stream reporter p ctx)))
           (on-end-parent (p)
             (report-end stream reporter p ctx))
           (on-child (test)
             (eval-test test)
             (let ((result (test-result test)))
               (when (null result)
                 (error "Test ~A has no result after being run." test))
               (when (and signal-condition-on-error?
                          (not (eql :ok (test-result-status result))))
                 (error 'test-error :reason (test-result-description result)))
               (report-result stream reporter test ctx))))
      (dotests test-parent #'on-child #'on-start-parent #'on-end-parent sequencer))))

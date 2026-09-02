(in-package #:lustre-tests)

(defparameter *root-test-parent* nil
  "The root of the test hierarchy. Execute all tests by invoking TEST.")

(defun init-root ()
  "Get the root TEST-PARENT, creating one if necessary."
  (if *root-test-parent*
      *root-test-parent*
      (setf *root-test-parent* (make-instance 'test-parent :name 'ROOT))))

(defun clear-tests ()
  "Deletes all tests from the default TEST-PARENT root."
  (setf *root-test-parent* nil))

(defun make-test-name (name)
  "Convert the name to a SYMBOL."
  (typecase name
    (string (intern name))
    (symbol name)
    (number (intern (format nil "~D" name)))
    (otherwise (error "Name must be string | symbol | number."))))

(defmacro define-test! (name (&rest parents) (class-name &rest keys &key &allow-other-keys) &body body)
  "Add a test of type CLASS-NAME to the framework.
If PARENTS are given, the test location matching the names of the parents is found or created.
A test passes if it does not signal any conditions. Hence, it's common to use ASSERT and similar
forms in tests.
The test class must have at least the following initargs (normally inherited from SIMPLE-TEST):
  - :NAME name of the test
  - :BODY the body of the test (for error reporting)
  - :FUN the function that runs the test
  - :PKG the package the test is defined at
Returns the created TEST."
  (let ((test-name (gensym))
        (test (gensym))
        (fun (gensym)))
    `(let* ((,test-name (make-test-name ',name))
            (,fun (setf (symbol-function ,test-name) (lambda () ,@body)))
            (,test (funcall #'make-instance
                            ,class-name
                            :name ,test-name
                            :body '(,@body)
                            :fun ,fun
                            :pkg *package*
                            ,@keys)))
       (add-test ,test
                 (init-root)
                 (mapcar #'make-test-name ',parents))
       ,test)))

(defmacro define-test (name (&rest parents) &body body)
  "Add a test of type SIMPLE-TEST to the framework.
If PARENTS are given, the test location matching the names of the parents is found or created.
A test passes if it does not signal any conditions. Hence, it's common to use ASSERT and similar
forms in tests.
Use DEFINE-TEST! for more custom options.
Returns the created TEST."
  `(define-test! ,name (,@parents) ('simple-test) ,@body))

(defun test (&key
               (test-parent (init-root))
               (stream *standard-output*)
               (sequencer (make-instance 'simple-test-sequencer))
               (reporter (make-instance 'ansi-test-reporter))
               (signal-condition-on-error? nil)
               (parallel? T))
  "Run all tests.
The test protocol is as follows:
  - report-start
  - sequence-tests
  - eval-test (for each test)
  - report-result (for each test)
  - report-end
If SIGNAL-CONDITION-ON-ERROR? is NIL, test evaluation proceeds as normal,
otherwise a TEST-ERROR condition is signalled on each test failure or error.
If PARALLEL? is NIL, tests run on the caller Thread, otherwise each
TEST-PARENT runs its children on a different Thread."
  (let ((ctx nil)
        (start-times nil)
        (results nil))
    (flet ((on-start-parent (p)
             (push (get-internal-real-time) start-times)
             (push (list T) results)
             (setf ctx (report-start stream reporter p ctx)))
           (on-end-parent (p)
             (let ((time (- (get-internal-real-time) (pop start-times)))
                   (result (pop results)))
               (setf (test-result p)
                     (make-instance 'test-result
                                    :status (if (car result) :ok :failed)
                                    :duration time)))
             (setf ctx (report-end stream reporter p ctx)))
           (on-child (test)
             (if signal-condition-on-error?
                 (eval-test test)
                 (handler-bind ((test-error
                                  #'(lambda (c)
                                      (declare (ignore c))
                                      (invoke-restart 'continue))))
                   (eval-test test)))
             (let ((result (test-result test)))
               (unless result
                 (error "Test ~A has no result after being run." (test-name test)))
               (unless (test-passed? test)
                 (let ((this-result (car results)))
                   (setf (car this-result) nil)))
               (report-result stream reporter test ctx))))
      (let ((iterate (if parallel? #'dotests-parallel #'dotests)))
        (funcall iterate test-parent #'on-child #'on-start-parent #'on-end-parent sequencer)))))

(defun test-simple (&key
                      (test-parent (init-root))
                      (stream *standard-output*)
                      (sequencer (make-instance 'simple-test-sequencer))
                      (signal-condition-on-error? nil)
                      (parallel? nil))
  "Call TEST with the REPORTER set to an instance of SIMPLE-TEST-REPORTER."
  (test :test-parent test-parent
        :stream stream
        :sequencer sequencer
        :signal-condition-on-error? signal-condition-on-error?
        :reporter (make-instance 'simple-test-reporter)
        :parallel? parallel?))

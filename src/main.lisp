(in-package #:lustre-tests)

(defparameter *tests* nil
  "List of TEST-INSTANCE objects. Execute all tests by invoking TEST.")

;;; CLASSES ;;;

(defclass test-result ()
  ((status :reader test-result-status :initarg :status :initform :ok)
   (description :reader test-result-description :initarg :description :initform nil))
  (:documentation "The result of running a test.
It should be pretty-printable so it can be shown in test reports."))

(defclass test-instance ()
  ((name :reader test-name :initarg :name
         :initform (error "must supply :name"))
   (body :reader test-body :initarg :body
         :initform (error "must supply :body"))
   (result :accessor test-result :initarg :result
           :initform nil))
  (:documentation "A test object. Usually created by the deftest macro.
Tests can be evaluated individually by EVAL-TEST.
To execute all tests in *TESTS*, invoke TEST."))

(defclass test-parent ()
  ((children :reader children :initarg :children :initform nil))
  (:documentation "A grouping of TEST-INSTANCE. When run, all children are run."))

(defclass test-reporter ()
  ((ok-count :initform 0)
   (fail-count :initform 0)
   (error-count :initform 0))
  (:documentation "An abstract test report writer."))

(defclass ansi-test-reporter (test-reporter)
  ((ansi-enabled :initarg :ansi-enabled :initform T))
  (:documentation "Default TEST-REPORTER. Uses FORMAT-ANSI to provide colorful terminal reports."))

;;; FACTORY FUNCTIONS ;;;

(defun make-test-result (status &optional description)
  (make-instance 'test-result
                 :status status
                 :description description))

;;; METHODS ;;;

(defmethod print-object ((result test-result) stream)
  (let ((full-format "#<TEST-RESULT ~A, ~A>")
        (short-format "#<TEST-RESULT ~A>"))
    (with-slots (status description) result
      (if description
          (format stream full-format status description)
          (format stream short-format status)))))

(defmethod make-load-form ((result test-result) &optional environment)
  (make-load-form-saving-slots result :environment environment))

(defgeneric report-start (stream reporter tests)
  (:method (stream (reporter ansi-test-reporter) tests)
    (unless tests (error "No tests added"))
    (ansi:format-ansi stream `((:fg :green "== LUSTRE TESTS ==")
                               ,(format nil "~%Running ~A test(s).~%" (length tests))))))

(defgeneric report-test-result (stream reporter test)
  (:documentation "Reports the result of each TEST.")

  (:method (stream (reporter test-reporter) (test test-instance))
    (case (test-result-status (test-result test))
      (:ok (incf (slot-value reporter 'ok-count)))
      (:error (incf (slot-value reporter 'error-count)))
      (otherwise (incf (slot-value reporter 'fail-count)))))

  (:method (stream (reporter ansi-test-reporter) (test test-instance))
    (call-next-method)
    (let ((result (test-result test)))
      (case (test-result-status result)
        (:ok
         (ansi:format-ansi stream `((:fg :green "OK: ")
                                    (:st :bold ,(test-name test))
                                    ,(string #\Newline))))
        (:error
         (ansi:format-ansi stream `((:fg :red "ERROR: ")
                                    (:st :bold ,(test-name test))
                                    ,(format nil " ~A~%" (test-result-description result)))))
        (otherwise
         (ansi:format-ansi stream `((:fg :yellow ,(format stream "~A: " (test-result-status result)))
                                    (:st :bold :fg :red ,(test-name test))
                                    ,(format nil " ~A~%" (test-result-description result)))))))))

(defgeneric report-end (stream reporter tests)
  (:documentation "Report the end of a test run.")
  (:method (stream (reporter test-reporter) tests)
    (with-slots (ok-count fail-count error-count) reporter
      (format T "Success: ~A, Failures: ~A, Errors: ~A~%" ok-count fail-count error-count))))

(defmethod eval-test ((test test-instance))
  "Evaluate this test.
   Returns the TEST-INSTANCE with its result having been set."
  (let* ((result (handler-case
                     (eval (test-body test))
                   (error (e) (make-test-result :error e))))
         (t-result (typecase result
                     (test-result result)
                     (T ;; consider the result a BOOLEAN meaning OK
                      (make-test-result
                       (if result :ok :fail)
                       (if result
                           nil
                           (format nil "~A => ~A" (test-body test) result)))))))
    (setf (test-result test) t-result)
    test))

(defmethod eval-test ((test test-parent))
  "Evaluate the children of a TEST-PARENT."
  (dolist (child (children test)) (eval-test child))
  test)

;;; FRAMEWORK FUNCTIONS AND MACROS ;;;

(defmacro deftest (name (&optional parent) &body body)
  "Add a test to the framework.
If the parent is given, the test is added to it instead of *TESTS*.
The body should return NIL to pass. Use an assertion macro to set up proper error messages."
  (let ((test-container (or parent '*tests*)))
    `(push (make-instance 'test-instance :name ,name :body '(progn ,@body)) ,test-container)))

(defun test (&optional (stream *standard-output*) (reporter (make-instance 'ansi-test-reporter)))
  "Run all tests in *TESTS*.
REPORTER will be called as follows:
    - REPORT-START
    - REPORT-TEST-RESULT
    - REPORT-END"
  (report-start stream reporter *tests*)
  (dolist (test *tests*) ;; TODO handle test-parent
    (report-test-result stream reporter (eval-test test)))
  (report-end stream reporter *tests*))

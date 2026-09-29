(in-package #:lustre-tests)

(defclass test-result ()
  ((status :reader test-result-status :initarg :status :initform :ok)
   (duration :reader test-duration :initarg :duration :initform 0)
   (description :reader test-result-description :initarg :description :initform nil))
  (:documentation "The result of running a test.
It should be pretty-printable so it can be shown in test reports.
By default, the recognized STATUS are :OK and :IGNORED (checked by methods
TEST-PASSED? and TEST-IGNORED?, respectively).
Anything else is considered as a failure.
Adding custom status requires specializing EVAL-TEST (to produce custom status)
and optionally TEST-REPORTER (to report such status differently than as failures).
The DURATION should be in REAL-TIME units."))

(defclass test-parent ()
  ((name :reader test-name :initarg :name
         :initform (error "test-parent name must be provided"))
   (children :accessor test-children :initarg :children :initform nil)
   (result :accessor test-result :initarg :result :initform nil))
  (:documentation "A group of tests.
All TEST-OBJECT instances should be added to a TEST-PARENT so they can be run by the TEST function.
Use the DEFINE-TEST or ADD-TEST forms for that purpose."))

(defclass test-object ()
  ((name :reader test-name :initarg :name
         :initform (error "test-object name must be provided"))
   (result :accessor test-result :initarg :result
           :initform nil)
   (enabled :accessor test-enabled? :initarg :enabled :initform T))
  (:documentation "A test object. Usually created by the DEFINE-TEST macro.
Tests can be evaluated individually by EVAL-TEST. After the test runs,
it should have a non-null RESULT which is a TEST-RESULT.
To execute all tests, invoke TEST."))

(defclass test-reporter () ()
  (:documentation "A TEST-REPORTER is responsible for reporting test results as tests are run."))

(defclass test-sequencer () ()
  (:documentation "A TEST-SEQUENCER is responsible for deciding the order in which tests should run.
It can also do other things, such as skip disabled tests, let tests run more than once etc.
It must not create tests itself."))

(define-condition test-error (error)
  ((reason :initarg :reason :reader test-error-reason
           :initform "Test error."))
  (:documentation "A TEST-ERROR is a condition triggered when a test or set of tests did not run successfully.")
  (:report (lambda (condition stream)
             (format stream "~A~%" (test-error-reason condition)))))

(define-condition test-done (error)
  ((result :initarg :result :reader test-done-result
           :initform (error "Must provide :result initarg")))
  (:documentation "A condition that can interrupt a test with a specific TEST-RESULT.")
  (:report (lambda (condition stream)
             (format stream "~A~%" (test-done-result condition)))))

(defgeneric dotests (parent on-child
                     &optional on-start-parent on-end-parent sequencer)
  (:documentation "Iterate over a TEST-PARENT's children, calling the callbacks as appropriate.
ON-START-PARENT and ON-END-PARENT are called for each child that is a TEST-PARENT.
ON-CHILD is called for each non-TEST-PARENT child.
The SEQUENCER should be used to determine the order of test iteration."))

(defgeneric dotests-parallel (parent on-child
                              &optional on-start-parent on-end-parent sequencer)
  (:documentation "Like DOTESTS, but runs tests in parallel.
ON-START-PARENT and ON-END-PARENT are called for each child that is a TEST-PARENT.
ON-CHILD is called for each non-TEST-PARENT child.
The SEQUENCER should be used to determine the order of test iteration."))

(defgeneric eval-test (test)
  (:documentation "Run a TEST-OBJECT.
Return the TEST-OBJECT with its TEST-RESULT having been set.")
  (:method ((test test-object))
    (error "EVAL-TEST not implemented for TEST-OBJECT.")))

(defgeneric test-passed? (test)
  (:documentation "Whether a test passed.
A test normally passed if its TEST-RESULT-STATUS is set to :OK.")
  (:method ((test test-result)) (eq :OK (test-result-status test)))
  (:method ((test test-object)) (test-passed? (test-result test))))

(defgeneric test-ignored? (test)
  (:documentation "Whether a test was ignored (because it was disabled).")
  (:method ((test test-result)) (eq :IGNORED (test-result-status test)))
  (:method ((test test-object)) (test-ignored? (test-result test))))

(defgeneric test-failed? (test)
  (:documentation "Whether a test failed.
By default, a test is assumed to have failed unless
TEST-PASSED? OR TEST-IGNORED? returns T.")
  (:method ((test test-result)) (not (or (test-passed? test)
                                         (test-ignored? test))))
  (:method ((test test-object)) (test-failed? (test-result test))))

(defgeneric sequence-tests (sequencer tests)
  (:documentation "Returns a LIST of tests to run based on the given TESTS.")
  (:method ((sequencer test-sequencer) tests)
    (error "SEQUENCE-TESTS not implemented for TEST-SEQUENCER.")))

(defgeneric sequence-parents (sequencer parents)
  (:documentation "Returns a LIST of TEST-PARENTs to run.")
  (:method ((sequencer test-sequencer) parents)
    (error "SEQUENCE-PARENTS not implemented for TEST-SEQUENCER.")))

(defgeneric report-start (stream reporter test ctx)
  (:documentation "Reports that a TEST-OBJECT or TEST-PARENT is about to start running.
Returns the CTX for the next calls.
The CTX parameter is nil on the first call.")
  (:method (stream (reporter test-reporter) test ctx)
    (error "REPORT-START not implemented for TEST-REPORTER.")))

(defgeneric report-end (stream reporter test ctx)
  (:documentation "Reports a TEST-OBJECT or TEST-PARENT has finished running.
Returns the CTX for the next calls.")
  (:method (stream (reporter test-reporter) test ctx)
    (error "REPORT-END not implemented for TEST-REPORTER.")))

(defgeneric report-result-description (stream reporter indent test description ctx)
  (:documentation "Reports the TEST-RESULT-DESCRIPTION for a TEST-OBJECT.
This method allows describing precisely why a test failed.
Unlike the other TEST-REPORTER methods, this method is not called directly by the
TEST function. Most implementations of REPORT-RESULT are expected to call it so
that it's possible to customize the result description without having to create a
full reporter type.")
  (:method (stream (reporter test-reporter) indent (test test-object) description ctx)
    (error "REPORT-RESULT-DESCRIPTION not implemented for TEST-REPORTER.")))

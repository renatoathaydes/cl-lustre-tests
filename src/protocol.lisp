(in-package #:lustre-tests)

(defclass test-result ()
  ((status :reader test-result-status :initarg :status :initform :ok))
  (:documentation "The result of running a test.
It should be pretty-printable so it can be shown in test reports."))

(defclass test-parent ()
  ((children :accessor test-children :initarg :children :initform nil))
  (:documentation "A group of tests.
All TEST-OBJECT should be added to a TEST-PARENT so it can be run by the TEST function."))

(defclass test-object ()
  ((result :accessor test-result :initarg :result
           :initform nil)
   (enabled :accessor :test-enabled? :initarg :enabled :initform T))
  (:documentation "A test object. Usually created by the define-test macro.
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
             (format stream "Test Error: ~A~&" (test-error-reason condition)))))

(defgeneric eval-test (test)
  (:documentation "Run a TEST-OBJECT.
Return the TEST-OBJECT with its TEST-RESULT having been set.")
  (:method ((test test-object))
    (error "EVAL-TEST not implemented for TEST-OBJECT.")))

(defgeneric sequence-tests (sequencer tests)
  (:documentation "Returns a LIST of tests to run based on the given TESTS.")
  (:method ((sequencer test-sequencer) tests)
    (error "SEQUENCE-TESTS not implemented for TEST-SEQUENCER.")))

(defgeneric sequence-parents (sequencer parents)
  (:documentation "Returns a LIST of TEST-PARENTs to run.")
  (:method ((sequencer test-sequencer) parents)
    (error "SEQUENCE-PARENTS not implemented for TEST-SEQUENCER.")))

(defgeneric report-start (stream reporter parent)
  (:documentation "Reports that tests in the PARENT are about to start running.")
  (:method (stream (reporter test-reporter) parent)
    (error "REPORT-START not implemented for TEST-REPORTER.")))

(defgeneric report-result (stream reporter test)
  (:documentation "Reports a test result.")
  (:method (stream (reporter test-reporter) (test test-object))
    (error "REPORT-RESULT not implemented for TEST-REPORTER.")))

(defgeneric report-end (stream reporter parent)
  (:documentation "Reports that tests in the PARENT have finished running.")
  (:method (stream (reporter test-reporter) parent)
    (error "REPORT-END not implemented for TEST-REPORTER.")))


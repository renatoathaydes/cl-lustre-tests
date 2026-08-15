(in-package #:lustre-tests)

(defclass test-result ()
  ((status :reader test-result-status :initarg :status :initform :ok))
  (:documentation "The result of running a test.
It should be pretty-printable so it can be shown in test reports."))

(defclass test-object ()
  ((result :accessor test-result :initarg :result
           :initform nil)
   (enabled :accessor :test-enabled? :initarg :enabled :initform T))
  (:documentation "A test object. Usually created by the deftest macro.
Tests can be evaluated individually by EVAL-TEST. After the test runs,
it should have a non-null RESULT which is a TEST-RESULT.
To execute all tests, invoke TEST."))

(defclass test-reporter () ()
  (:documentation "A TEST-REPORTER is responsible for reporting test results as tests are run."))

(defclass test-sequencer () ()
  (:documentation "A TEST-SEQUENCER is responsible for deciding the order in which tests should run.
It can also do other things, such as skip disabled tests, let tests run more than once etc.
It must not create tests itself."))

(defgeneric eval-test (test)
  (:documentation "Run a TEST-OBJECT.")
  (:method ((test test-object))
    (error "EVAL-TEST not implemented for TEST-OBJECT.")))

(defgeneric sequence-tests (sequencer tests)
  (:documentation "Returns a LIST of tests to run based on the given TESTS.")
  (:method ((sequencer test-sequencer) tests)
    (error "SEQUENCE-TESTS not implemented for TEST-SEQUENCER.")))

(defgeneric report-start (stream reporter tests)
  (:documentation "Reports that tests are about to start running.")
  (:method (stream (reporter test-reporter) tests)
    (error "REPORT-START not implemented for TEST-REPORTER.")))

(defgeneric report-result (stream reporter test)
  (:documentation "Reports a test result.")
  (:method (stream (reporter test-reporter) (test test-object))
    (error "REPORT-RESULT not implemented for TEST-REPORTER.")))

(defgeneric report-end (stream reporter tests)
  (:documentation "Reports that all tests in the previous REPORT-START call have run.")
  (:method (stream (reporter test-reporter) tests)
    (error "REPORT-END not implemented for TEST-REPORTER.")))


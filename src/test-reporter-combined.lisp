(in-package #:lustre-tests)

(defclass combined-test-reporter (test-reporter)
  ((delegates :initarg :delegates :reader test-reporter-delegates))
  (:documentation "A TEST-REPORTER that combines other TEST-REPORTER instances."))

(defmethod report-start (stream (reporter combined-test-reporter) test ctx)
  (let ((delegates (test-reporter-delegates reporter)))
    (loop for delegate in delegates
          with contexts = (or ctx (make-list (length delegates)))
          for context in contexts
          collect (report-start stream delegate test context))))

(defmethod report-end (stream (reporter combined-test-reporter) test ctx)
  (let ((delegates (test-reporter-delegates reporter)))
    (loop for delegate in delegates
          with contexts = (or ctx (make-list (length delegates)))
          for context in contexts
          collect (report-end stream delegate test context))))

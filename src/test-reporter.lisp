(in-package #:lustre-tests)

(defclass counting-test-reporter (test-reporter)
  ((ok-count :initform 0)
   (fail-count :initform 0)
   (error-count :initform 0))
  (:documentation "An abstract test report writer that counts each test-result status."))

(defclass ansi-test-reporter (counting-test-reporter)
  ((ansi-enabled :initarg :ansi-enabled :initform T))
  (:documentation "Default TEST-REPORTER. Uses FORMAT-ANSI to provide colorful terminal reports."))

(defmethod report-start (stream (reporter ansi-test-reporter) tests)
  (unless tests (error "No tests added"))
  (ansi:format-ansi stream `((:fg :green "== LUSTRE TESTS ==")
                             ,(format nil "~%Running ~A test(s).~%" (length tests)))))

(defmethod report-result (stream (reporter counting-test-reporter) (test test-object))
  (case (test-result-status (test-result test))
    (:ok (incf (slot-value reporter 'ok-count)))
    (:error (incf (slot-value reporter 'error-count)))
    (otherwise (incf (slot-value reporter 'fail-count)))))

(defmethod report-result (stream (reporter ansi-test-reporter) (test test-object))
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
                                  ,(format nil " ~A~%" (test-result-description result))))))))

(defmethod report-end (stream (reporter counting-test-reporter) tests)
  (with-slots (ok-count fail-count error-count) reporter
    (format T "Success: ~A, Failures: ~A, Errors: ~A~%" ok-count fail-count error-count)))

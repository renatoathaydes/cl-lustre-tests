(in-package #:lustre-tests)

(defclass counting-test-reporter (test-reporter)
  ((ok-count :initform 0)
   (fail-count :initform 0)
   (error-count :initform 0))
  (:documentation "An abstract test report writer that counts each test-result status."))

(defclass simple-test-reporter (counting-test-reporter)
  ()
  (:documentation "A simple TEST-REPORTER. Suitable for interactive Lisp sessions."))

(defclass ansi-test-reporter (counting-test-reporter)
  ((ansi-enabled :initarg :ansi-enabled :initform T
                 :accessor ansi-enabled?))
  (:documentation "Default TEST-REPORTER. Uses FORMAT-ANSI to provide colorful terminal reports."))

(defun create-ctx (parent)
  "A ctx is a cons with the indentation and the root parent."
  (cons "" parent))

(defun increment-indent (ctx)
  (cons (concatenate 'string "  " (car ctx)) (cdr ctx)))

(defmethod report-start (stream (reporter simple-test-reporter) parent ctx)
  (if (null ctx)
      (progn
        (format stream "== LUSTRE TESTS ==~%~%Running ~A test(s).~%" (count-tests parent))
        (create-ctx parent))
      (progn
        (format stream "  ~A>> ~A~%" (car ctx) (test-name parent))
        (increment-indent ctx))))

(defmethod report-start (stream (reporter ansi-test-reporter) parent ctx)
  (if (null ctx)
      (progn
        (ansi:format-ansi
         stream
         `(("== LUSTRE TESTS ==~%")
           (:st :italic "Running ~A test(s).~%" ,(count-tests parent))))
        (create-ctx parent))
      (progn
        (ansi:format-ansi
         stream
         `((:st :bold :fg :cyan "  ~A>> ~A~%" ,(car ctx) ,(test-name parent))))
        (increment-indent ctx))))

(defmethod report-result (stream (reporter counting-test-reporter) (test test-object) ctx)
  (case (test-result-status (test-result test))
    (:ok (incf (slot-value reporter 'ok-count)))
    (:error (incf (slot-value reporter 'error-count)))
    (otherwise (incf (slot-value reporter 'fail-count)))))

(defmethod report-result (stream (reporter simple-test-reporter) (test test-object) ctx)
  (call-next-method)
  (let ((result (test-result test)))
    (case (test-result-status (test-result test))
      (:ok (format stream "~AOK: ~A~%" (car ctx) (test-name test)))
      (otherwise (format stream "~A~A: ~A~%~A~%"
                         (car ctx)
                         (test-result-status result)
                         (test-name test)
                         (test-result-description result))))))

(defmethod report-result (stream (reporter ansi-test-reporter) (test test-object) ctx)
  (call-next-method)
  (let ((result (test-result test)))
    (case (test-result-status result)
      (:ok
       (ansi:format-ansi stream `((:fg :green "~AOK: " ,(car ctx))
                                  (:st :bold "~A~%" ,(test-name test)))))
      (:error
       (ansi:format-ansi stream `((:fg :red "~AERROR: " ,(car ctx))
                                  (:fg :red :st :bold "~A~%" ,(test-name test))
                                  (:fg :red "~A~%" ,(test-result-description result)))))
      (otherwise
       (ansi:format-ansi stream `((:fg :yellow "~A~A: " ,(car ctx) ,(test-result-status result))
                                  (:fg :yellow :st :bold "~A~%" ,(test-name test))
                                  (:fg :yellow "~A~%" ,(test-result-description result))))))))

(defmethod report-end (stream (reporter counting-test-reporter) parent ctx)
  (when (eq (cdr ctx) parent)
    (with-slots (ok-count fail-count error-count) reporter
      (format stream "Success: ~A, Failures: ~A, Errors: ~A~%" ok-count fail-count error-count))))

(defmethod report-end (stream (reporter ansi-test-reporter) parent ctx)
  (when (eq (cdr ctx) parent)
    (with-slots (ok-count fail-count error-count) reporter
      (ansi:format-ansi stream
                        `((:fg :green "Success: ~A, " ,ok-count)
                          (:fg :yellow "Failures: ~A, " ,fail-count)
                          (:fg :red "Errors: ~A~%" ,error-count))))))

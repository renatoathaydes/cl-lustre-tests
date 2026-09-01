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

(defun decrement-indent (ctx)
  (let* ((indent (car ctx))
         (len (length indent)))
    (if (zerop len)
        ctx
        (cons (subseq indent 0 (- len 2)) (cdr ctx)))))

(defmethod report-start (stream (reporter simple-test-reporter) (parent test-parent) ctx)
  (if (null ctx)
      (progn
        (format stream "== LUSTRE TESTS ==~%~%Running ~A test(s).~%" (count-tests parent))
        (create-ctx parent))
      (progn
        (format stream "  ~A>> ~A~%" (car ctx) (test-full-name parent))
        (increment-indent ctx))))

(defmethod report-start (stream (reporter ansi-test-reporter) (parent test-parent) ctx)
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
         `((:st :bold :fg :cyan "  ~A>> ~A~%" ,(car ctx) ,(test-full-name parent))))
        (increment-indent ctx))))

(defmethod report-result-description (stream
                                      (reporter counting-test-reporter)
                                      (test test-object)
                                      description
                                      ctx)
  (format stream "~A~%" description))

(defmethod report-result-description (stream
                                      (reporter counting-test-reporter)
                                      (test simple-test)
                                      description
                                      ctx)
  (format stream "~A =>~%    ~A~%" (test-body test) description))

(defmethod report-result-description (stream
                                      (reporter ansi-test-reporter)
                                      (test simple-test)
                                      description
                                      ctx)
  (lustre-tests/color-sexp:color-sexp (test-body test) stream)
  (format stream " =>~%    ~A~%" description))

(defmethod report-result (stream (reporter counting-test-reporter) (test test-object) ctx)
  (case (test-result-status (test-result test))
    (:ok (incf (slot-value reporter 'ok-count)))
    (:error (incf (slot-value reporter 'error-count)))
    (otherwise (incf (slot-value reporter 'fail-count)))))

(defun print-duration (duration stream)
  (write-char #\( stream)
  (time:print-time duration stream)
  (write-char #\) stream)
  (terpri stream))

(defmethod report-result (stream (reporter simple-test-reporter) (test test-object) ctx)
  (call-next-method)
  (let* ((result (test-result test))
         (duration (test-duration result)))
    (case (test-result-status result)
      (:ok
       (format stream "~AOK: ~A " (car ctx) (test-full-name test))
       (print-duration duration stream))
      (otherwise (let ((desc (test-result-description result)))
                   (format stream "~A~A: ~A~%"
                           (car ctx)
                           (test-result-status result)
                           (test-full-name test))
                   (report-result-description stream reporter test desc ctx))))))

(defmethod report-result (stream (reporter ansi-test-reporter) (test test-object) ctx)
  (call-next-method)
  (let* ((name (test-full-name test))
         (result (test-result test))
         (duration (test-duration result))
         (desc (test-result-description result)))
    (case (test-result-status result)
      (:ok
       (ansi:format-ansi stream `((:fg :green "~AOK: " ,(car ctx))
                                  (:st :bold "~A " ,name)))
       (print-duration duration stream))
      (:error
       (ansi:format-ansi stream `((:fg :red "~AERROR: " ,(car ctx))
                                  (:fg :red :st :bold "~A " ,name)))
       (print-duration duration stream)
       (report-result-description stream reporter test desc ctx))
      (otherwise
       (ansi:format-ansi stream `((:fg :yellow "~A~A: " ,(car ctx) ,(test-result-status result))
                                  (:fg :yellow :st :bold "~A " ,name)))
       (print-duration duration stream)
       (report-result-description stream reporter test desc ctx)))))

(defmethod report-end (stream (reporter counting-test-reporter) (parent test-parent) ctx)
  (cond
    ((eq (cdr ctx) parent)
     (with-slots (ok-count fail-count error-count) reporter
       (format stream "Success: ~A, Failures: ~A, Errors: ~A " ok-count fail-count error-count))
     (print-duration (test-duration (test-result parent)) stream))
    (T
     (format stream "~A<< ~A " (car ctx) (test-name parent))
     (print-duration (test-duration (test-result parent)) stream)))
  ctx)

(defmethod report-end (stream (reporter simple-test-reporter) (parent test-parent) ctx)
  (decrement-indent (call-next-method)))

(defmethod report-end (stream (reporter ansi-test-reporter) (parent test-parent) ctx)
  (cond
    ((eq (cdr ctx) parent)
     (with-slots (ok-count fail-count error-count) reporter
       (ansi:format-ansi stream
                         `((:fg :green "Success: ~A, " ,ok-count)
                           (:fg :yellow "Failures: ~A, " ,fail-count)
                           (:fg :red "Errors: ~A " ,error-count))))
     (print-duration (test-duration (test-result parent)) stream))
    (T
     (ansi:format-ansi stream `(("~A" ,(car ctx))
                                (:st :bold :fg :cyan "<< ~A " ,(test-name parent))))
     (print-duration (test-duration (test-result parent)) stream)))
  (decrement-indent ctx))

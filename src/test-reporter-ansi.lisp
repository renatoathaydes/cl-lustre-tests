(in-package #:lustre-tests)

(defconstant +gray+ 8)

(defclass ansi-test-reporter (base-test-reporter)
  ((ansi-enabled :initarg :ansi-enabled :initform T
                 :accessor ansi-enabled?))
  (:documentation "Default TEST-REPORTER. Uses FORMAT-ANSI to provide colorful terminal reports."))

(defmethod report-start (stream (reporter ansi-test-reporter) (parent test-parent) ctx)
  (cond
    ((null ctx)
     (let ((format-ansi:*enabled* (ansi-enabled? reporter)))
       (ansi:format-ansi
        stream
        `(("== LUSTRE TESTS ==~%")
          (:st :italic "Running ~A test(s).~%" ,(count-tests parent)))))
     (create-ctx parent))
    (T
     (when (eq (test-reporter-mode reporter) :full)
       (let ((format-ansi:*enabled* (ansi-enabled? reporter)))
         (ansi:format-ansi
          stream
          `((:st :bold :fg :cyan "  ~A>> ~A~%" ,(car ctx) ,(test-full-name parent))))))
     (increment-indent ctx))))

(defmethod report-result-description (stream
                                      (reporter ansi-test-reporter)
                                      indent
                                      (test simple-test)
                                      description
                                      ctx)
  (cs:color-sexp (test-body test) stream)
  (format stream " =>~%~A  ~A~%" indent description))

(defmethod report-end (stream (reporter ansi-test-reporter) (test test-object) ctx)
  (call-next-method)
  (let* ((name (test-full-name test))
         (result (test-result test))
         (duration (test-duration result))
         (indent (car ctx))
         (desc (test-result-description result))
         (format-ansi:*enabled* (ansi-enabled? reporter)))
    (cond
      ((test-passed? result)
       (when (eq (test-reporter-mode reporter) :full)
         (ansi:format-ansi stream `((:fg :green "~AOK: " ,indent)
                                    (:st :bold "~A " ,name)))
         (print-duration duration stream)))
      ((test-ignored? result)
       (when (eq (test-reporter-mode reporter) :full)
         (ansi:format-ansi stream `((:fg ,+gray+ "~AIGNORED: " ,indent)
                                    (:st :bold "~A~%" ,name)))))
      (T
       (ansi:format-ansi stream `((:fg :red "~A~A: " ,indent ,(test-result-status result))
                                  (:fg :red :st :bold "~A " ,name)))
       (print-duration duration stream)
       (report-result-description stream reporter indent test desc ctx))))
  ctx)

(defmethod report-end (stream (reporter ansi-test-reporter) (parent test-parent) ctx)
  (let ((format-ansi:*enabled* (ansi-enabled? reporter)))
    (cond
      ((eq (cdr ctx) parent)
       (with-slots (ok-count ignored-count fail-count) reporter
         (ansi:format-ansi stream
                           `((:fg :green "Success: ~A, " ,ok-count)
                             (:fg ,+gray+ "Ignored: ~A, " ,ignored-count)
                             (:fg :red "Failures: ~A " ,fail-count))))
       (print-duration (test-duration (test-result parent)) stream))
      (T
       (unless (eq (test-reporter-mode reporter) :quiet)
         (ansi:format-ansi stream `(("~A" ,(car ctx))
                                    (:st :bold :fg :cyan "<< ~A " ,(test-name parent))))
         (print-duration (test-duration (test-result parent)) stream)))))
  (decrement-indent ctx))

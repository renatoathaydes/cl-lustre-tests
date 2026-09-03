(in-package #:lustre-tests)

(defconstant +gray+ 8)

(deftype test-reporter-mode () `(member :full :parents :quiet))

(defclass base-test-reporter (test-reporter)
  ((ok-count :initform 0)
   (ignored-count :initform 0)
   (fail-count :initform 0)
   (mode :initarg :mode :initform :full
         :type test-reporter-mode
         :accessor test-reporter-mode))
  (:documentation "An abstract test reporteer that counts each test-result status.
It also has a logging MODE, which can be one of:
  * :FULL - log every test and test-parent.
  * :PARENTS - log every test-parent.
  * :QUIET - log only the number of tests."))

(defclass simple-test-reporter (base-test-reporter) ()
  (:documentation "A simple TEST-REPORTER. Suitable for interactive Lisp sessions.
The MODE can be one of:
  * :FULL - log every test and test-parent.
  * :PARENTS - log every test-parent.
  * :QUIET - log only the number of tests."))

(defclass ansi-test-reporter (base-test-reporter)
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
  (cond 
    ((null ctx)
     (format stream "== LUSTRE TESTS ==~%Running ~A test(s).~%" (count-tests parent))
     (create-ctx parent))
    (T
     (when (eq (test-reporter-mode reporter) :full)
       (format stream "  ~A>> ~A~%" (car ctx) (test-full-name parent)))
     (increment-indent ctx))))

(defmethod report-start (stream (reporter ansi-test-reporter) (parent test-parent) ctx)
  (cond
    ((null ctx)
     (ansi:format-ansi
      stream
      `(("== LUSTRE TESTS ==~%")
        (:st :italic "Running ~A test(s).~%" ,(count-tests parent))))
     (create-ctx parent))
    (T
     (when (eq (test-reporter-mode reporter) :full)
       (ansi:format-ansi
        stream
        `((:st :bold :fg :cyan "  ~A>> ~A~%" ,(car ctx) ,(test-full-name parent)))))
     (increment-indent ctx))))

(defmethod report-result-description (stream
                                      (reporter base-test-reporter)
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

(defmethod report-result (stream (reporter base-test-reporter) (test test-object) ctx)
  (cond
    ((test-passed? test) (incf (slot-value reporter 'ok-count)))
    ((test-ignored? test) (incf (slot-value reporter 'ignored-count)))
    (T (incf (slot-value reporter 'fail-count)))))

(defun print-duration (duration stream)
  (write-char #\( stream)
  (time:print-time duration stream)
  (write-char #\) stream)
  (terpri stream))

(defmethod report-result (stream (reporter simple-test-reporter) (test test-object) ctx)
  (call-next-method)
  (let* ((result (test-result test))
         (duration (test-duration result)))
    (cond
      ((test-passed? result)
       (when (eq (test-reporter-mode reporter) :full)
         (format stream "~AOK: ~A " (car ctx) (test-full-name test))
         (print-duration duration stream)))
      ((test-ignored? result)
       (when (eq (test-reporter-mode reporter) :full)
         (format stream "~AIGNORED: ~A~%" (car ctx) (test-full-name test))))
      (T (let ((desc (test-result-description result)))
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
    (cond
      ((test-passed? result)
       (when (eq (test-reporter-mode reporter) :full)
         (ansi:format-ansi stream `((:fg :green "~AOK: " ,(car ctx))
                                    (:st :bold "~A " ,name)))
         (print-duration duration stream)))
      ((test-ignored? result)
       (when (eq (test-reporter-mode reporter) :full)
         (ansi:format-ansi stream `((:fg ,+gray+ "~AIGNORED: " ,(car ctx))
                                    (:st :bold "~A~%" ,name)))))
      (T
       (ansi:format-ansi stream `((:fg :red "~A~A: " ,(car ctx) ,(test-result-status result))
                                  (:fg :red :st :bold "~A " ,name)))
       (print-duration duration stream)
       (report-result-description stream reporter test desc ctx)))))

(defmethod report-end (stream (reporter base-test-reporter) (parent test-parent) ctx)
  (cond
    ((eq (cdr ctx) parent)
     (with-slots (ok-count ignored-count fail-count) reporter
       (format stream "Success: ~A, Ignored: ~A, Failures: ~A " ok-count ignored-count fail-count))
     (print-duration (test-duration (test-result parent)) stream))
    (T
     (unless (eq (test-reporter-mode reporter) :quiet)
       (format stream "~A<< ~A " (car ctx) (test-name parent))
       (print-duration (test-duration (test-result parent)) stream))))
  ctx)

(defmethod report-end (stream (reporter simple-test-reporter) (parent test-parent) ctx)
  (decrement-indent (call-next-method)))

(defmethod report-end (stream (reporter ansi-test-reporter) (parent test-parent) ctx)
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
       (print-duration (test-duration (test-result parent)) stream))))
  (decrement-indent ctx))

(in-package #:lustre-tests)

(defparameter +tests+ nil)

;;; CLASSES ;;;

(defclass test-result ()
  ((status :reader test-status :initarg :status :initform :ok)
   (description :reader test-result-description :initarg :description :initform nil)))

(defclass test-instance ()
  ((name :reader test-name :initarg :name
         :initform (error "must supply :name"))
   (body :reader test-body :initarg :body
         :initform (error "must supply :body"))
   (result :accessor test-result :initarg :result
           :initform nil)))

;;; METHODS ;;;

(defun make-test-result (status &optional description)
  (make-instance 'test-result
                 :status status
                 :description description))

(defmethod print-object ((result test-result) stream)
  (let ((full-format "#<TEST-RESULT ~A, ~A>")
        (short-format "#<TEST-RESULT ~A>"))
    (with-slots (status description) result
      (if description
          (format stream full-format status description)
          (format stream short-format status)))))

(defmethod make-load-form ((result test-result) &optional environment)
  (make-load-form-saving-slots result :environment environment))

(defmethod eval-test ((test test-instance))
  "Evaluate this test.
   Returns the TEST-INSTANCE with its result having been set."
  (let* ((result (handler-case
                     (funcall (test-body test))
                   (error (e) (make-test-result :error e))))
         (t-result (typecase result
                     (test-result result)
                     (T ;; consider the result a BOOLEAN meaning OK
                      (make-test-result
                       (if result :ok :fail)
                       (if result
                           nil
                           (format nil "~A" (test-body test))))))))
    (setf (test-result test) t-result)
    test))

;;; FRAMEWORK FUNCTIONS AND MACROS ;;;

(defmacro deftest (name &body body)
  "Add a test to the framework.
   The body should return NIL to pass. Use an assertion macro to set up proper error messages."
  `(push (make-instance 'test-instance :name ,name :body '(progn ,@body)) +tests+))

(defun test ()
  (when (null +tests+) (error "No tests added"))
  (ansi:format-ansi T `((:fg :green "== LUSTRE TESTS ==")
                        ,(format nil "~%Running ~A test(s).~%" (length +tests+))))
  (let ((ok-count 0)
        (fail-count 0)
        (error-count 0))
    (dolist (test +tests+)
      (eval-test test)
      (let ((result (test-result test)))
        (case (test-status result)
          (:ok
           (incf ok-count)
           (ansi:format-ansi T `((:fg :green "OK: ")
                                 (:st :bold ,(test-name test))
                                 ,(string #\Newline))))
          (:error
           (incf error-count)
           (ansi:format-ansi T `((:fg :red "ERROR: ")
                                 (:st :bold ,(test-name test))
                                 ,(format nil " ~A~%" (cdr result)))))
          (T
           (incf fail-count)
           (ansi:format-ansi T `((:fg :yellow ,(format nil "~A: " (car result)))
                                 (:st :bold :fg :red ,(test-name test))
                                 ,(format nil " ~A~%" (cdr result))))))))
    (format T "Success: ~A, Failures: ~A, Errors: ~A~%" ok-count fail-count error-count)))

(in-package #:lustre-tests)

(defclass simple-test (test-object)
  ((name :reader test-name :initarg :name
         :initform (error "must supply :name"))
   (body :reader test-body :initarg :body
         :initform (error "must supply :body")))
  (:documentation "A SIMPLE-TEST contains a BODY that is a form that can be evaluated when
the test runs."))

(defmethod eval-test ((test simple-test))
  "Evaluate this test.
   Returns the TEST-INSTANCE with its result having been set."
  (let* ((result (handler-case
                     (eval (test-body test))
                   (error (e) (make-test-result :error e))))
         (t-result (typecase result
                     (test-result result)
                     (T ;; consider the result a BOOLEAN meaning OK
                      (make-test-result
                       (if result :ok :fail)
                       (if result
                           nil
                           (format nil "~A => ~A" (test-body test) result)))))))
    (setf (test-result test) t-result)
    test))

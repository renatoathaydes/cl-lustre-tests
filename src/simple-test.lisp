(in-package #:lustre-tests)

(defclass simple-test (test-object)
  ((body :reader test-body :initarg :body
         :initform (error "must supply :body"))
   (fun :reader test-fun :initarg :fun
        :initform (error "must supply :fun")))
  (:documentation "A SIMPLE-TEST contains a BODY that is a form that can be evaluated when
the test runs."))

(defmethod eval-test ((test simple-test))
  "Evaluate this test.
   Returns the TEST-INSTANCE with its result having been set."
  (let* ((start-time (get-internal-real-time))
         (result (handler-case
                     (funcall (test-fun test))
                   (error (e) (make-instance 'simple-test-result
                                             :status :error
                                             :duration (- (get-internal-real-time) start-time)
                                             :description e))))
         (t-result (typecase result
                     (test-result result)
                     (T ;; consider the result a BOOLEAN meaning OK
                      (make-instance
                       'simple-test-result
                       :status (if result :ok :failed)
                       :duration (- (get-internal-real-time) start-time)
                       :description (unless result
                                      (with-output-to-string (s)
                                        (lustre-tests/color-sexp:color-sexp
                                         (test-body test) s)
                                        (format s " => ~A"  result))))))))
    (setf (test-result test) t-result)
    test))

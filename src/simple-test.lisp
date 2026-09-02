(in-package #:lustre-tests)

(defclass simple-test (test-object)
  ((body :reader test-body :initarg :body
         :initform (error "must supply :body"))
   (fun :reader test-fun :initarg :fun
        :initform (error "must supply :fun"))
   (pkg :reader test-package :initarg :pkg
        :initform nil))
  (:documentation "A SIMPLE-TEST contains a BODY that is a form that can be evaluated when
the test runs."))

(defun test-full-name (test)
  (let ((name (test-name test)))
    (if (typep test 'simple-test)
        (let ((pkg (test-package test)))
          (if pkg
              (format nil "~A::~A" (package-name pkg) name)
              name))
        name)))

(defmethod eval-test ((test simple-test))
  "Evaluate this test if it's enabled, otherwise set its TEST-RESULT with :IGNORED status.
   A test passes as long as no conditions were signalled.
   Returns the SIMPLE-TEST with its result having been set."
  (cond
    ((test-enabled? test)
     (let* ((start-time (get-internal-real-time))
            (result (handler-case
                        (funcall (test-fun test))
                      (error (e) (make-instance 'simple-test-result
                                                :status :error
                                                :duration (- (get-internal-real-time) start-time)
                                                :description e))))
            (t-result (typecase result
                        (test-result result)
                        (T ;; no conditions so the test passed
                         (make-instance
                          'simple-test-result
                          :status :ok
                          :duration (- (get-internal-real-time) start-time))))))
       (setf (test-result test) t-result)
       (unless (eq :ok (test-result-status t-result))
         (cerror "Ignore test failure." 'test-error
                 :reason (format nil "Test ~A failed.~%~A"
                                 (test-full-name test)
                                 (test-result-description t-result))))))
    (T
     (setf (test-result test)
           (make-instance 'simple-test-result
                          :status :ignored
                          :duration 0))))
  test)

(in-package #:lustre-tests)

(defclass simple-test-result (test-result)
  ((description :reader test-result-description :initarg :description :initform nil))
  (:documentation "The result of running a test.
It should be pretty-printable so it can be shown in test reports."))

(defun make-test-result (status &optional description)
  (make-instance 'simple-test-result
                 :status status
                 :description description))

(defmethod print-object ((result simple-test-result) stream)
  (let ((full-format "#<TEST-RESULT ~A, ~A>")
        (short-format "#<TEST-RESULT ~A>"))
    (with-slots (status description) result
      (if description
          (format stream full-format status description)
          (format stream short-format status)))))

;;(defmethod make-load-form ((result simple-test-result) &optional environment)
;;  (make-load-form-saving-slots result :environment environment))
;;

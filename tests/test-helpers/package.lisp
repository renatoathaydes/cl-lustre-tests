(defpackage #:lustre-tests/test-helpers
  (:use #:cl)
  (:export #:make-test-ok
           #:make-test-with-error
           #:ansi-seq)
  (:local-nicknames
   (#:lt #:lustre-tests)))

(in-package #:lustre-tests/test-helpers)

(defun make-test-ok (name &optional description)
  (make-instance 'lt:test-object
                 :name name
                 :result (make-instance 'lt:test-result
                                        :description description)))

(defun make-test-with-error (name error)
  (make-instance 'lt:test-object
                 :name name
                 :result (make-instance 'lt:test-result
                                        :status :error
                                        :description error)))

(defmacro ansi-seq (&rest body)
  (let ((transformed-body
          (loop for exp in body
                collect (etypecase exp
                          ((or string character) `(format out "~A" ,exp))
                          (list (if (listp (car exp))
                                    `(ansi:format-ansi out (list ,@exp))
                                    `(ansi:format-ansi out (list (list ,@exp)))))))))
    `(with-output-to-string (out) ,@transformed-body)))

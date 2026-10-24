(defpackage #:lustre-tests/test-helpers
  (:use #:cl)
  (:export #:make-test-ok
           #:make-test-with-error
           #:ansi-seq))

(in-package #:lustre-tests/test-helpers)

(defun make-test-ok (name &optional description)
  (make-instance 'lustre-tests:test-object
                 :name name
                 :result (make-instance 'lustre-tests:test-result
                                        :description description)))

(defun make-test-with-error (name error)
  (make-instance 'lustre-tests:test-object
                 :name name
                 :result (make-instance 'lustre-tests:test-result
                                        :status :error
                                        :description error)))

(defmacro ansi-seq (&rest body)
  (flet ((ensure-list (item)
           (typecase item
             (list
              (if (eq 'cl:list (car item))
                  item
                  (cons 'list item)))
             (T `(list ,item)))))
    (let ((transformed-body
            (loop for exp in body
                  collect (etypecase exp
                            ((or string character)
                             `(format out "~A" ,exp))
                            (list
                             (if (listp (car exp))
                                 (let ((lists (mapcar #'ensure-list exp)))
                                   `(ansi:format-ansi out (list ,@lists)))
                                 `(ansi:format-ansi out (list ,(ensure-list exp)))))))))
      `(with-output-to-string (out) ,@transformed-body))))

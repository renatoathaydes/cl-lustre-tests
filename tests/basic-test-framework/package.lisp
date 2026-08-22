(defpackage lustre-tests/basic-framework
  (:documentation "Tiniest test framework in the world.
    Tests are just functions whose names are pushed into *tests*.")
  (:use #:cl)
  (:local-nicknames
   (#:lt #:lustre-tests))
  (:export #:*tests*
           #:define-lustre-test
           #:assert-t
           #:assert-nil
           #:with-local-root))

(in-package #:lustre-tests/basic-framework)

(defparameter *tests* nil)

(defmacro define-lustre-test (name &body body)
  `(progn
     (defun ,name () ,@body)
     (pushnew ',name *tests*)))

(defmacro with-local-root ((root) &body body)
  `(let* ((lt::*root-test-parent*
            (make-instance 'lt:test-parent :name 'lt::ROOT))
          (,root
            lt::*root-test-parent*))
     ,@body))

(defmacro assert-t (&body body)
  `(assert (eq T (progn ,@body))))

(defmacro assert-nil (&body body)
  `(assert (null (progn ,@body))))

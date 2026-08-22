(defpackage lustre-tests/basic-framework
  (:documentation "Tiniest test framework in the world.
    Tests are just functions whose names are pushed into *tests*.")
  (:use #:cl)
  (:local-nicknames
   (#:lt #:lustre-tests))
  (:export #:*tests*
           #:define-lustre-test
           #:assert-strings-equal
           #:assert-t
           #:assert-nil
           #:with-local-root))

(in-package #:lustre-tests/basic-framework)

(defparameter *tests* nil)

(defmacro define-lustre-test (name &body body)
  `(progn
     (defun ,name () ,@body)
     (pushnew ',name *tests*)))

;; Hard to test ANSI output without an assertion to help with that.

(defun assert-strings-equal (test-name actual expected)
  (unless (string= expected actual)
    (error (with-output-to-string (s)
             (format s "~A FAILED~%" test-name)
             (format s "Expected: ~S~%" expected)
             (format s "Actual:   ~S~%" actual)
             (format s "Difference at position ~D:~%"
                     (or (mismatch expected actual) (length expected)))))))

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

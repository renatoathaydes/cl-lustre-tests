(in-package #:lustre-tests)

(defclass test-parent ()
  ((children :reader children :initarg :children :initform nil))
  (:documentation "A grouping of TEST-INSTANCE. When run, all children are run."))

(defmethod eval-test ((test test-parent))
  "Evaluate the children of a TEST-PARENT."
  (dolist (child (children test)) (eval-test child))
  test)

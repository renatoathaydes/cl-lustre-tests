(in-package #:lustre-tests)

(defclass simple-test-sequencer (test-sequencer)
  ((ordering :accessor test-sequencer-ordering :initarg :ordering :initform :declaration-order))
  (:documentation "Sequences tests according to the ORDERING chosen.
ORDERING can be one of:
  - :declaration-order
  - :reverse-declaration-order
  - :random
Tests that are disabled are not run."))

(defmethod sequence-tests ((sequencer test-sequencer) tests)
  (case (test-sequencer-ordering sequencer)
    (:declaration-order
     ;; the tests are added by push, hence in reverse declaration order.
     (reverse tests))
    (:reverse-declaration-order tests)
    ;; TODO shuffle the list
    (:random tests)))

(in-package #:lustre-tests)

(defclass simple-test-sequencer (test-sequencer)
  ((ordering :accessor test-sequencer-ordering :initarg :ordering :initform :declaration-order))
  (:documentation "Sequences tests according to the ORDERING chosen.
ORDERING can be one of:
  - :declaration-order
  - :reverse-declaration-order
  - :random
Tests that are disabled are not run."))

(defun shuffle (list)
  (let ((vector (coerce list 'vector)))
    (loop for i from (1- (length vector)) downto 1
          for j = (random (1+ i))
          do (rotatef (aref vector i) (aref vector j)))
    (coerce vector 'list)))

(defmethod sequence-tests ((sequencer simple-test-sequencer) tests)
  (ecase (test-sequencer-ordering sequencer)
    (:declaration-order
     ;; the tests are added by push, hence in reverse declaration order.
     (reverse tests))
    (:reverse-declaration-order tests)
    (:random (shuffle tests))))

(defmethod sequence-parents ((sequencer simple-test-sequencer) parents)
  (ecase (test-sequencer-ordering sequencer)
    (:declaration-order
     (reverse parents))
    (:reverse-declaration-order parents)
    (:random (shuffle parents))))

(in-package #:lustre-tests)

(defun add-test (test parent)
  "Adds a test to a parent."
  (push test (test-children parent)))

(defun count-tests (parent)
  "Count how many tests are included in the TEST-PARENT.
Recursively counts children that are also TEST-PARENT themselves.
Does not include other TEST-PARENTs in the result."
  (let ((result 0))
    (flet ((on-test (test)
             (declare (ignore test))
             (incf result)))
      (dotests parent #'on-test))
    result))

(defun partition-parents (parent)
  (loop for child in (test-children parent)
        if (typep child 'test-parent) collect child into parents
          else collect child into others
        finally (return (values parents others))))

(defun dotests (parent on-child
                &optional on-start-parent on-end-parent sequencer)
  "Iterate over each child in PARENT.
Children may be either a TEST-OBJECT or a TEST-PARENT.
First, the TEST-OBJECTs are iterated over. If there's any TEST-PARENT,
they are then iterated over, recursively.
ON-CHILD is called for each TEST-OBJECT.
ON-START-PARENT and ON-END-PARENT are called before/after each TEST-PARENT,
including the initial PARENT."
  (when on-start-parent
    (funcall on-start-parent parent))
  (multiple-value-bind (parents non-parents)
      (partition-parents parent)
    (dolist (child (if sequencer
                       (sequence-tests sequencer non-parents)
                       non-parents))
      (funcall on-child child))
    (dolist (next-parent (if sequencer
                             (sequence-parents sequencer parents)
                             parents))
      (dotests next-parent on-child on-start-parent on-end-parent)))
  (when on-end-parent
    (funcall on-end-parent parent)))

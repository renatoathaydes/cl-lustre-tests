(in-package #:lustre-tests)

(defun tests-equalp (t1 t2)
  (and (eq (type-of t1) (type-of t2))
       (eq (test-name t1) (test-name t2))))

(defun find-child (name parent)
  (find-if (lambda (child)
             (eq name (test-name child)))
           (test-children parent)))

(defun add-child (test parent)
  "Add a TEST to a PARENT, ensuring name uniqueness under the TEST-PARENT
by replacing any existing tests with the same name."
  (mapl (lambda (c)
          (when (tests-equalp test (car c))
            (setf (car c) test)
            (return-from add-child)))
        (test-children parent))
  (push test (test-children parent)))

(defun add-test (test parent &optional parent-names)
  "Add a TEST to a PARENT, using PARENT-NAMES to make or find intermediate test parents."
  (if (null parent-names)
      (add-child test parent)
      (let ((new-parent (make-instance 'test-parent :name (car parent-names))))
        (add-child new-parent parent)
        (add-test test new-parent (cdr parent-names)))))

(defun print-test-tree (parent &optional (stream *standard-output*))
  "Print a test tree."
  (let ((indent ""))
    (flet ((on-start-parent (p)
             (format stream "~A* ~A~%" indent (test-name p))
             (setf indent (concatenate 'string indent "  ")))
           (on-end-parent (p)
             (declare (ignore p))
             (setf indent (subseq indent 0 (- (length indent) 2))))
           (on-child (c)
             (format stream "~A- ~A~%" indent (test-name c))))
      (dotests parent #'on-child #'on-start-parent #'on-end-parent))))

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

(in-package #:lustre-tests)

(defparameter *max-diff-items-to-display* 64
  "The maximum number of individual element matches to display
when EXPECT-SEQ fails, starting from the first element mismatch.")

(defparameter *max-displayed-items-before-diff* 20
  "The maximum number of items in a sequence to show before the diff starts")

(defun subvec (seq start end)
  (coerce (subseq seq start end) 'vector))

(defun fill-shorter (s1 s2)
  (let ((l1 (file-position s1))
        (l2 (file-position s2)))
    (cond
      ((= l1 l2) nil)
      ((> l1 l2) (dotimes (n (- l1 l2)) (princ #\SPACE s2)))
      (T (dotimes (n (- l2 l1)) (princ #\SPACE s1))))))

(defun print-diff (stream expected actual matches prefix expected-suffix actual-suffix diff-index)
  (let ((index 0)
        (diff-print-index 0)
        (es (make-string-output-stream))
        (as (make-string-output-stream)))
    ;; loop only to the shorter sequence length
    (loop for e across expected
          for a across actual
          do (progn
               (when (= index diff-index)
                 (setf diff-print-index (file-position es)))
               (format es "~A " e)
               (format as "~A " a)
               (fill-shorter es as)
               (incf index)))
    ;; now loop to the rest of the longer sequence
    (multiple-value-bind (seq st)
        (cond
          ((> (length actual) (length expected))
           (values actual as))
          ((< (length actual) (length expected))
           (values expected es))
          (T (values nil nil)))
      (loop for i from index below (length seq)
            do (when (= i diff-index)
                 (setf diff-print-index (file-position st)))
            do (format st "~A " (aref seq i))))
    (format stream "Expected: ~A~A~A~%" prefix (get-output-stream-string es) expected-suffix)
    (format stream "Actual:   ~A~A~A~%" prefix (get-output-stream-string as) actual-suffix)
    (format stream "          ~v@t~a~%" (+ (length prefix) diff-print-index) "^")
    (format stream "Changes:  ~A" matches)))

(defun expect-seq (expected actual &optional (test 'equal))
  "Returns NIL is the sequence are equal, or a SIMPLE-TEST-RESULT
with a failure description otherwise."
  (multiple-value-bind (matches distance)
      (edit-distance:diff expected actual :test test)
    (if (> distance 0)
        (let* ((first-diff-index (position-if-not
                                  (lambda (m) (eq (car m) :match))
                                  matches))
               (first-shown-index (max
                                   0
                                   (- first-diff-index *max-displayed-items-before-diff*)))
               (expected-length (length expected))
               (actual-length (length actual))
               (max-shown-index (+ first-shown-index *max-diff-items-to-display*))
               (expected-last-index (min max-shown-index expected-length))
               (actual-last-index (min max-shown-index actual-length))
               (last-diff-index (min max-shown-index (max expected-length actual-length)))
               (prefix (if (> first-shown-index 0) "..." ""))
               (expected-suffix (if (< expected-last-index expected-length) "..." ""))
               (actual-suffix (if (< actual-last-index actual-length) "..." "")))
          (make-instance
           'simple-test-result
           :status :failed
           :description (with-output-to-string (s)
                          (format s "Levenshtein distance: ~D, first diff at ~D, showing from ~D to ~D~%"
                                  distance
                                  first-diff-index
                                  first-shown-index
                                  max-shown-index)
                          (print-diff s
                                      (subvec expected first-shown-index expected-last-index)
                                      (subvec actual first-shown-index actual-last-index)
                                      (subvec matches first-diff-index last-diff-index)
                                      prefix
                                      expected-suffix
                                      actual-suffix
                                      (- first-diff-index first-shown-index)))))
        T)))

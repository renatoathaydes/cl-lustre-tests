(in-package #:lustre-tests)

(defparameter *max-diff-items-to-display* 64
  "The maximum number of individual element matches to display
when EXPECT-SEQ fails, starting from the first element mismatch.")

(defparameter *max-displayed-items-before-diff* 20
  "The maximum number of items in a sequence to show before the diff starts")

(defun subvec (seq start end)
  (coerce (subseq seq start end) 'vector))

(defun print-diff (stream expected actual matches prefix expected-suffix actual-suffix)
  (let ((expected-len (length expected))
        (actual-len (length actual))
        (es (make-string-output-stream)) ;; expected stream
        (as (make-string-output-stream)) ;; actual stream
        (ms (make-string-output-stream)) ;; matches stream
        (ei 0) ;; expected index
        (ai 0)) ;; actual index
    (labels ((print-e (e)
               (format es "~A~A" e (if (= (incf ei) expected-len) "" " ")))
             (print-a (a)
               (format as "~A~A" a (if (= (incf ai) actual-len) "" " ")))
             (print-e-and-a (e a)
               (print-e e)
               (print-a a))
             (spaces (len)
               (if (> len 1)
                   (make-string len :initial-element #\SPACE)
                   ""))
             (fill-shorter (s1 s2 s3)
               (let ((l1 (if s1 (file-position s1) 0))
                     (l2 (if s2 (file-position s2) 0))
                     (l3 (file-position s3)))
                 (let ((len (max l1 l2 l3)))
                   (when s1 (princ (spaces (- len l1)) s1))
                   (when s2 (princ (spaces (- len l2)) s2))
                   (princ (spaces (- len l3)) s3)))))
      (loop for i from 0 below (length matches)
            for e = (if (< ei expected-len) (aref expected ei) #\SPACE)
            for a = (if (< ai actual-len) (aref actual ai) #\SPACE)
            for m = (aref matches i)
            do (ecase (car m)
                 (:match (print-e-and-a e a))
                 (:substitution
                  (print-e-and-a e a)
                  (princ "~" ms))
                 (:insertion
                  (print-a a)
                  (princ "+" ms))
                 (:deletion
                  (print-e e)
                  (princ "-" ms)))
            do (fill-shorter
                (when (< ei expected-len) es)
                (when (< ai actual-len) as)
                ms))
      (format stream "Expected: ~A~A~A~%" prefix (get-output-stream-string es) expected-suffix)
      (format stream "Actual:   ~A~A~A~%" prefix (get-output-stream-string as) actual-suffix)
      (format stream "          ~A~A" (spaces (length prefix)) (get-output-stream-string ms)))))

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
                                  (max expected-last-index actual-last-index))
                          (print-diff s
                                      (subvec expected first-shown-index expected-last-index)
                                      (subvec actual first-shown-index actual-last-index)
                                      (subvec matches first-shown-index last-diff-index)
                                      prefix
                                      expected-suffix
                                      actual-suffix))))
        T)))

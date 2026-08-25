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
        (strings? (and
                   (typep expected '(vector character))
                   (typep actual '(vector character))))
        (es (make-string-output-stream)) ;; expected stream
        (as (make-string-output-stream)) ;; actual stream
        (ms (make-string-output-stream)) ;; matches stream
        (ei 0) ;; expected index
        (ai 0)) ;; actual index
    (labels ((print-char (char stream)
               (let ((code (char-code char)))
                 (if
                  ;; ESC character (27), control characters (0-31, 127)
                  (or (= code 27) (< code 32) (= code 127))
                  (format stream "\\x~2,'0X" code)
                  (write-char char stream))))
             (print-e (e)
               (if strings? (print-char e es) (format es "~A" e))
               (unless (= (incf ei) expected-len) (write-char #\SPACE es)))
             (print-a (a)
               (if strings? (print-char a as) (format as "~A" a))
               (unless (= (incf ai) actual-len) (write-char #\SPACE as)))
             (print-e-and-a (e a)
               (print-e e)
               (print-a a))
             (spaces (stream len)
               (if (> len 0)
                   (if stream
                       (loop repeat len do (write-char #\SPACE stream))
                       (make-string len :initial-element #\SPACE))
                   ""))
             (fill-shorter (s1 s2 s3)
               (let ((l1 (if s1 (file-position s1) 0))
                     (l2 (if s2 (file-position s2) 0))
                     (l3 (file-position s3)))
                 (let ((len (max l1 l2 l3)))
                   (when s1 (spaces s1 (- len l1)))
                   (when s2 (spaces s2 (- len l2)))
                   (spaces s3 (- len l3))))))
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
               ;; the indexes have been incremented here, so we check them again
            do (fill-shorter (when (< ei expected-len) es) (when (< ai actual-len) as) ms))
      (format stream "Expected: ~A~A~A~%" prefix (get-output-stream-string es) expected-suffix)
      (format stream "Actual:   ~A~A~A~%" prefix (get-output-stream-string as) actual-suffix)
      (format stream "          ~A~A" (spaces nil (length prefix)) (get-output-stream-string ms)))))

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

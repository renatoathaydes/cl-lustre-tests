(in-package #:lustre-tests)

(defparameter *max-diff-matches-to-display* 20
  "The maximum number of individual element matches to display
when EXPECT-SEQ fails, starting from the first element mismatch.")

(defun expect-seq (expected actual &optional (test 'equal))
  "Returns NIL is the sequence are equal, or a SIMPLE-TEST-RESULT
with a failure description otherwise."
  (multiple-value-bind (matches distance)
      (edit-distance:diff expected actual :test test)
    (if (> distance 0)
        (let* ((first-diff-index (position-if-not
                                  (lambda (m) (eq (car m) :match))
                                  matches))
               (last-diff-index (min
                                 (+ first-diff-index *max-diff-matches-to-display*)
                                 (length matches))))
          (make-instance
           'simple-test-result
           :status :failed
           :description (with-output-to-string (s)
                          (format s "Levenshtein distance: ~D, first diff at ~D~%~A~%"
                                  distance
                                  first-diff-index
                                  (subseq matches first-diff-index last-diff-index))
                          (edit-distance:print-diff expected actual
                                                    :file-stream s
                                                    :test test
                                                    :prefix1 "expected"
                                                    :prefix2 "actual"))))
        T)))

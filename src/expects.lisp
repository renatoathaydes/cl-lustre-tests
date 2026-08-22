(in-package #:lustre-tests)

(defun expect-seq (expected actual &optional (test 'equal))
  "Returns NIL is the sequence are equal, or a SIMPLE-TEST-RESULT
with a failure description otherwise."
  (let ((distance (nth-value 1 (edit-distance:diff expected actual :test test))))
    (if (> distance 0)
        (make-instance
         'simple-test-result
         :status :failed
         :description (with-output-to-string (s)
                        (edit-distance:print-diff expected actual
                                                  :file-stream s
                                                  :test test
                                                  :prefix1 "expected"
                                                  :prefix2 "actual")))
        T)))

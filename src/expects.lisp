(in-package #:lustre-tests)

(defparameter *max-diff-items-to-display* 64
  "The maximum number of individual element matches to display
when EXPECT-SEQ fails, starting from the first element mismatch.")

(defparameter *max-displayed-items-before-diff* 20
  "The maximum number of items in a sequence to show before the diff starts")

(defparameter *show-diff-with-ansi-colors* nil
  "Whether to show diffs using ANSI colors.")

(defclass expects-output-stream
    (trivial-gray-streams:fundamental-character-output-stream)
  ((delegate :reader delegate-stream :initform (make-string-output-stream))
   (visible-chars :initform 0 :reader visible-chars)))

(defun sync-visible-positions (s1 s2 s3)
  (flet ((fill-spaces (len stream)
           (loop repeat len do (write-char #\SPACE stream))))
    (let* ((c1 (visible-chars s1))
           (c2 (visible-chars s2))
           (c3 (visible-chars s3))
           (max (max c1 c2 c3)))
      (fill-spaces (- max c1) s1)
      (fill-spaces (- max c2) s2)
      (fill-spaces (- max c3) s3))))

(defmacro with-color (color (&rest streams) &body body)
  (flet ((printing (stream reset?)
           `(when ,color
              (with-slots (delegate) ,stream
                (ansi::print-ansi :bg ,(if reset? :reset color) delegate)))))
    (let ((calls (mapcar (lambda (s) (printing s nil)) streams))
          (resets (mapcar (lambda (s) (printing s T)) streams)))
      `(progn ,@calls ,@body ,@resets))))

(defmethod trivial-gray-streams:stream-write-char
    ((stream expects-output-stream) char)
  (with-slots (delegate visible-chars) stream
    (let ((code (char-code char)))
      (incf visible-chars
            (cond
              ;; ESC character (27), control characters (0-31, 127)
              ((or (= code 27) (< code 32) (= code 127))
               (format delegate "\\x~2,'0X" code)
               4)
              (T
               (write-char char delegate)
               1))))
    char))

(defmethod trivial-gray-streams:stream-line-column
    ((stream expects-output-stream))
  (with-slots (delegate) stream
    (trivial-gray-streams:stream-line-column delegate)))

(defun print-diff (stream strings? matches prefix
                   expected-suffix actual-suffix)
  (let ((ansi? *show-diff-with-ansi-colors*)
        (len (length matches))
        (es (make-instance 'expects-output-stream))
        (as (make-instance 'expects-output-stream))
        (ms (make-instance 'expects-output-stream)))
    (labels ((print-item (item last? stream)
               (if strings?
                   (write-char item stream)
                   (format stream "~A" item))
               (unless (or last? (and strings? ansi?))
                 (write-char #\SPACE stream))))
      (loop for i from 0 below len
            for m = (aref matches i)
            for last? = (= (1+ i) len)
            ;; each match has the form:
            ;;   (:match expected actual)
            ;;   (:substitution expected actual)
            ;;   (:insertion nil actual)
            ;;   (:deletion expected nil)
            do (ecase (first m)
                 (:match
                     (print-item (second m) last? es) (print-item (third m) last? as))
                 (:substitution
                  (with-color (when ansi? :yellow) (es as)
                    (print-item (second m) last? es) (print-item (third m) last? as))
                  (unless ansi? (princ "~" ms)))
                 (:insertion
                  (with-color (when ansi? :green) (as)
                    (print-item (third m) last? as))
                  (unless ansi? (princ "+" ms)))
                 (:deletion
                  (with-color (when ansi? :red) (es)
                    (print-item (second m) last? es))
                  (unless ansi? (princ "-" ms))))
            do (sync-visible-positions es as ms))
      (when ansi? (ansi::print-ansi :fg :reset stream))
      (format stream "Expected: ~A~A~A~%" prefix (get-output-stream-string
                                                  (delegate-stream es))
              expected-suffix)
      (format stream "Actual:   ~A~A~A" prefix (get-output-stream-string
                                                (delegate-stream as))
              actual-suffix)
      (unless ansi?
        (format stream "~%          ~A~A"
                (make-string (length prefix) :initial-element #\SPACE)
                (get-output-stream-string (delegate-stream ms)))))))

(defun expect-seq (expected actual &key (test 'equal))
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
               (max-shown-index (+ first-diff-index (1- *max-diff-items-to-display*)))
               (expected-last-index (min max-shown-index (1- expected-length)))
               (actual-last-index (min max-shown-index (1- actual-length)))
               (prefix (if (> first-shown-index 0) "..." ""))
               (expected-suffix (if (< expected-last-index (1- expected-length)) "..." ""))
               (actual-suffix (if (< actual-last-index (1- actual-length)) "..." "")))
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
                                      (and
                                       (typep expected '(vector character))
                                       (typep actual '(vector character)))
                                      (coerce (subseq matches
                                                      first-shown-index
                                                      (min (length matches) (1+ max-shown-index)))
                                              'vector)
                                      prefix
                                      expected-suffix
                                      actual-suffix))))
        T)))

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
   (items :initarg :items :reader stream-items)
   (index :initform 0 :accessor item-index)
   (visible-chars :initform 0 :reader visible-chars)))

(defun stream-done (stream)
  (with-slots (items index) stream
    (>= index (length items))))

(defun next-item (stream)
  (with-slots (items index) stream
    (when (< index (length items))
      (let ((result (aref items index)))
        (incf index)
        result))))

(defun sync-visible-positions (s1 s2 s3)
  (flet ((fill-spaces (len stream)
           (unless (stream-done stream)
             (loop repeat len do (write-char #\SPACE stream)))))
    (let* ((c1 (visible-chars s1))
           (c2 (visible-chars s2))
           (c3 (visible-chars s3))
           (max (max c1 c2 c3)))
      (fill-spaces (- max c1) s1)
      (fill-spaces (- max c2) s2)
      (fill-spaces (- max c3) s3))))

(defmacro with-color (color (&rest streams) &body body)
  (flet ((printing (stream bg-color)
           `(when ,bg-color
              (with-slots (delegate) ,stream
                (ansi::print-ansi :bg ,bg-color delegate)))))
    (let ((calls (mapcar (lambda (s) (printing s color)) streams))
          (resets (mapcar (lambda (s) (printing s :reset)) streams)))
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

(defun subvec (seq start end)
  (coerce (subseq seq start end) 'vector))

(defun print-diff (stream expected actual matches prefix
                   expected-suffix actual-suffix)
  (let ((strings? (and
                   (typep expected '(vector character))
                   (typep actual '(vector character))))
        (ansi? *show-diff-with-ansi-colors*)
        (es (make-instance 'expects-output-stream
                           :items expected))
        (as (make-instance 'expects-output-stream
                           :items actual))
        (ms (make-instance 'expects-output-stream
                           :items matches)))
    (labels ((print-item (item stream)
               (if strings?
                   (write-char item stream)
                   (format stream "~A" item))
               (unless (or ansi? (stream-done stream))
                 (write-char #\SPACE stream))))
      (loop for e = (next-item es)
            for a = (next-item as)
            for m = (next-item ms)
            while m
            do (ecase (car m)
                 (:match (print-item e es) (print-item a as))
                 (:substitution
                  (with-color (when ansi? :yellow) (es as)
                    (print-item e es) (print-item a as))
                  (unless ansi? (princ "~" ms)))
                 (:insertion
                  (with-color (when ansi? :green) (as) (print-item a as))
                  (unless ansi? (princ "+" ms)))
                 (:deletion
                  (with-color (when ansi? :red) (es) (print-item e es))
                  (unless ansi? (princ "-" ms))))
            do (sync-visible-positions es as ms))
      (ansi::print-ansi :fg :reset stream)
      (format stream "Expected: ~A~A~A~%" prefix (get-output-stream-string
                                                  (delegate-stream es))
              expected-suffix)
      (format stream "Actual:   ~A~A~A~%" prefix (get-output-stream-string
                                                  (delegate-stream as))
              actual-suffix)
      (unless ansi?
        (format stream "          ~A~A"
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

(in-package #:lustre-tests/color-sexp)

(defparameter *symbol-color* nil)
(defparameter *string-color* nil)
(defparameter *char-color* nil)
(defparameter *number-color* nil)

(defparameter *gray-foreground* 248)

(defun color-sexp (sexp &optional (stream *standard-output*) action)
  "Colorize S-expression, printing the result to STREAM."
  (case action
    ((:start-list nil) (princ #\( stream))
    (:start-array (princ #\[ stream)))
  (when (eql action :start) )
  (loop for term being the elements of sexp
        with first? = T
        do (unless first? (princ #\SPACE stream))
        do (let ((color (typecase term
                          (symbol (or *symbol-color* :cyan))
                          ((vector character) (or *string-color* :magenta))
                          (character (or *char-color* :bmagenta))
                          (number (or *number-color* :red))
                          (cons (color-sexp term stream :start-list))
                          (array (color-sexp term stream :start-array))
                          (T *gray-foreground*))))
             (when color
               (ansi:format-ansi stream `((:fg ,color "~S" ,term)))))
        do (setf first? nil))
  (case action
    (:start-list (princ #\) stream))
    (:start-array (princ #\] stream)))
  nil)
        
(defun color-sexp-to-string (sexp)
  "Colorize S-expression, returning the result as a STRING."
  (with-output-to-string (s)
    (color-sexp sexp s)))
        

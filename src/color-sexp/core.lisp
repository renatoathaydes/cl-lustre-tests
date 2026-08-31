(in-package #:lustre-tests/color-sexp)

(defparameter *string-color* nil)
(defparameter *char-color* nil)
(defparameter *number-color* nil)
(defparameter *keyword-color* nil)
(defparameter *symbol-color* nil)
(defparameter *special-operator-color* nil)
(defparameter *standard-macro-color* nil)
(defparameter *lambda-list-keyword-color* nil)

(defconstant +default-color+ 240)
(defconstant +default-string-color+ 128)
(defconstant +default-char-color+ 129)
(defconstant +default-number-color+ 33)
(defconstant +default-keyword-color+ 39)
(defconstant +default-symbol-color+ 241)
(defconstant +default-special-operator-color+ 208)
(defconstant +default-standard-macro-color+ 210)
(defconstant +default-lambda-list-keyword-color+ 39)

(defun special-operator? (s)
  (member s '(block catch eval-when flet function go if labels let let*
              load-time-value locally macrolet multiple-value-call
              multiple-value-prog1 progn progv quote return-from setq
              symbol-macrolet tagbody the throw unwind-protect)
          :test #'eq))

(defun standard-macro? (s)
  (member s '(defun defmacro defpackage defvar defparameter defclass defparameter
              defmethod defgeneric defstruct deftype defsetf defglobal
              lambda do dotimes dolist setf cond econd case ecase)
          :test #'eq))

(defun color-for-symbol (s)
  (cond
    ((special-operator? s)
     (or *special-operator-color* +default-special-operator-color+))
    ((standard-macro? s)
     (or *standard-macro-color* +default-standard-macro-color+))
    ((eq (char (symbol-name s) 0) #\&)
     (or *lambda-list-keyword-color* +default-lambda-list-keyword-color+))
    (T
     (or *symbol-color* +default-symbol-color+))))

(defun color-sexp (sexp &optional (stream *standard-output*) (pkg *package*) action)
  "Colorize S-expression, printing the result to STREAM."
  (ecase action
    ((:start-list nil) (princ #\( stream))
    (:start-array (princ #\[ stream)))
  (when (eql action :start) )
  (loop for term being the elements of sexp
        with first? = T
        do (unless first? (princ #\SPACE stream))
        do (multiple-value-bind (color format-str)
               (typecase term
                 (keyword (values (or *keyword-color* +default-keyword-color+) "~S"))
                 (symbol (values (color-for-symbol term)
                                 (if (eq pkg (symbol-package term)) "~A" "~S")))
                 ((vector character) (values (or *string-color* +default-string-color+) "~S"))
                 (character (values (or *char-color* +default-char-color+) "~S"))
                 (number (values (or *number-color* +default-number-color+) "~A"))
                 (cons (values (color-sexp term stream pkg :start-list) ""))
                 (array (values (color-sexp term stream pkg :start-array) ""))
                 (T (values +default-color+ "~A")))
             (when color
               (ansi:format-ansi stream `((:fg ,color ,format-str ,term)))))
        do (setf first? nil))
  (ecase action
    ((:start-list nil) (princ #\) stream))
    (:start-array (princ #\] stream)))
  nil)

(defun color-sexp-to-string (sexp &optional (pkg *package*))
  "Colorize S-expression, returning the result as a STRING."
  (with-output-to-string (s)
    (color-sexp sexp s pkg)))

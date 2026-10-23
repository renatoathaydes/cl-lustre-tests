(in-package #:lustre-tests/color-sexp)

;; if adding more special vars, update thread.lisp!
(defparameter *string-color* nil)
(defparameter *char-color* nil)
(defparameter *number-color* nil)
(defparameter *keyword-color* nil)
(defparameter *symbol-color* nil)
(defparameter *special-operator-color* nil)
(defparameter *standard-macro-color* nil)
(defparameter *lambda-list-keyword-color* nil)
(defparameter *sexp-line-limit* 96
  "Maximum number of visible characters per line printed by COLOR-SEXP.
NIL disables line breaking.")

(defvar *column* 0
  "Visible column of the line being printed by COLOR-SEXP. The stream's own
column can't be used because it counts the characters of ANSI escape codes.")

(defconstant +default-color+ 248)
(defconstant +default-string-color+ 128)
(defconstant +default-char-color+ 129)
(defconstant +default-number-color+ 33)
(defconstant +default-keyword-color+ 39)
(defconstant +default-symbol-color+ 251)
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

(defun nested? (term)
  "True if TERM is printed between brackets (strings are printed as atoms)."
  (or (consp term)
      (and (arrayp term) (not (stringp term)))))

(defun atom-color-and-text (term pkg)
  "Return the color and the printed text of the atom TERM."
  (multiple-value-bind (color format-str)
      (typecase term
        (keyword (values (or *keyword-color* +default-keyword-color+) "~S"))
        (symbol (values (color-for-symbol term)
                        (if (eq pkg (symbol-package term)) "~A" "~S")))
        ((vector character) (values (or *string-color* +default-string-color+) "~S"))
        (character (values (or *char-color* +default-char-color+) "~@C"))
        (number (values (or *number-color* +default-number-color+) "~A"))
        (T (values +default-color+ "~A")))
    (values color (format nil format-str term))))

(defun fits? (term pkg available)
  "True if TERM, printed on a single line, takes at most AVAILABLE columns.
Gives up as soon as AVAILABLE is exhausted, so it never measures more than one line's worth."
  (labels ((consume (n)
             (when (minusp (decf available n))
               (return-from fits? nil)))
           (walk (term)
             (if (nested? term)
                 (let ((first? T))
                   (consume 2)
                   (map nil (lambda (x)
                              (if first? (setf first? nil) (consume 1))
                              (walk x))
                        term))
                 (consume (length (nth-value 1 (atom-color-and-text term pkg)))))))
    (walk term)
    T))

(defun emit (stream text &optional color)
  "Print TEXT to STREAM, keeping track of the visible column."
  (if color
      (ansi:format-ansi stream `((:fg ,color "~A" ,text)))
      (write-string text stream))
  (incf *column* (length text)))

(defun new-line (stream indent)
  (format stream "~%~vA" indent "")
  (setf *column* indent))

(defun print-nested (seq stream pkg flat?)
  "Print SEQ between brackets. Unless FLAT?, elements that do not fit in the
current line go on a new line, indented relative to the opening bracket."
  (let ((indent (+ *column* (if (and (consp seq) (symbolp (car seq))) 2 1)))
        (first? T))
    (emit stream (if (consp seq) "(" "["))
    (map nil (lambda (term)
               (let ((fits? (or flat?
                                (fits? term pkg (- *sexp-line-limit* *column*
                                                   (if first? 0 1))))))
                 (cond (first? (setf first? nil))
                       (fits? (emit stream " "))
                       (T (new-line stream indent)))
                 (print-term term stream pkg fits?)))
         seq)
    (emit stream (if (consp seq) ")" "]"))))

(defun print-term (term stream pkg flat?)
  (if (nested? term)
      (print-nested term stream pkg flat?)
      (multiple-value-bind (color text) (atom-color-and-text term pkg)
        (emit stream text color))))

(defun color-sexp (sexp &optional (stream *standard-output*) (pkg *package*))
  "Colorize S-expression, printing the result to STREAM.
Lines are broken to keep them within *SEXP-LINE-LIMIT* visible characters where possible."
  (let ((*column* 0))
    (print-term sexp stream pkg (null *sexp-line-limit*)))
  nil)

(defun color-sexp-to-string (sexp &optional (pkg *package*))
  "Colorize S-expression, returning the result as a STRING."
  (with-output-to-string (s)
    (color-sexp sexp s pkg)))

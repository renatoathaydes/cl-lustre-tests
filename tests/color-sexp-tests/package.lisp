(defpackage lustre-tests/color-sexp/tests
  (:documentation "lustre-tests/color-sexp tests.")
  (:use #:cl #:lustre-tests/test-helpers))

(in-package #:lustre-tests/color-sexp/tests)

(defpackage my-symbols
  (:export #:foo))

(lustre-tests:define-test colors-symbol (color-sexp)
  (lustre-tests:expect-seq
   (ansi-seq "(" (:fg lustre-tests/color-sexp:+default-symbol-color+ "MY-SYMBOLS:FOO") ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(my-symbols:foo))))

(lustre-tests:define-test colors-numbers (color-sexp)
  (lustre-tests:expect-seq
   (ansi-seq "(" (:fg lustre-tests/color-sexp:+default-number-color+ "10") ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(10))))

(lustre-tests:define-test colors-keywords (color-sexp)
  (lustre-tests:expect-seq
   (ansi-seq "(" (:fg lustre-tests/color-sexp:+default-keyword-color+ ":HELLO") ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(:hello))))

(lustre-tests:define-test colors-special-operators (color-sexp)
  (lustre-tests:expect-seq
   (ansi-seq "(" (:fg lustre-tests/color-sexp:+default-special-operator-color+ "FUNCTION") ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(function))))

(lustre-tests:define-test colors-chars-and-strings (color-sexp)
  (setf *print-readably* nil)
  (lustre-tests:expect-seq
   (ansi-seq "("
             (:fg lustre-tests/color-sexp:+default-char-color+ "#\\A")
             " "
             (:fg lustre-tests/color-sexp:+default-string-color+ "\"Joe\"")
             ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(#\A "Joe"))))

(lustre-tests:define-test colors-standard-macros (color-sexp)
  (lustre-tests:expect-seq
   (ansi-seq "(" (:fg lustre-tests/color-sexp:+default-standard-macro-color+ "DEFUN") ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(defun))))

(lustre-tests:define-test colors-lambda-list-keywords (color-sexp)
  (lustre-tests:expect-seq
   (ansi-seq "(" (:fg lustre-tests/color-sexp:+default-lambda-list-keyword-color+ "&OPTIONAL") ")")
   (lustre-tests/color-sexp:color-sexp-to-string '(&optional))))

(lustre-tests:define-test colors-full-expression (color-sexp)
  (setf *print-readably* nil)
  (let ((lustre-tests/color-sexp:*sexp-line-limit* nil))
    (lustre-tests:expect-seq
     (ansi-seq "("
               (:fg lustre-tests/color-sexp:+default-standard-macro-color+ "DEFUN")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "MY-FUN")
               " ("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "ARG")
               " "
               (:fg lustre-tests/color-sexp:+default-lambda-list-keyword-color+ "&KEY")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "K1")
               ") "
               (:fg lustre-tests/color-sexp:+default-string-color+ "\"My function.\"")
               " ("
               (:fg lustre-tests/color-sexp:+default-special-operator-color+ "LET")
               " (("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "X")
               " "
               (:fg lustre-tests/color-sexp:+default-char-color+ "#\\A")
               ")) ("
               (:fg lustre-tests/color-sexp:+default-standard-macro-color+ "DOLIST")
               " ("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "ITEM")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "K1")
               ") ("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "FORMAT")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "T")
               " "
               (:fg lustre-tests/color-sexp:+default-string-color+ "\"STR\"")
               " "
               (:fg lustre-tests/color-sexp:+default-keyword-color+ ":K")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "MY-SYMBOLS:FOO")
               " ("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "Y")
               " "
               (:fg lustre-tests/color-sexp:+default-number-color+ "2")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "X")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "ITEM")
               ")))))")
     (lustre-tests/color-sexp:color-sexp-to-string
      '(defun my-fun (arg &key k1)
        "My function."
        (let ((x #\A))
          (dolist (item k1) (format T "STR" :k my-symbols:foo (y 2 x item)))))
      (find-package :lustre-tests/color-sexp/tests)))))

(lustre-tests:define-test breaks-long-lines (color-sexp)
  (let ((lustre-tests/color-sexp:*sexp-line-limit* 20))
    (lustre-tests:expect-seq
     (ansi-seq "("
               (:fg lustre-tests/color-sexp:+default-standard-macro-color+ "DEFUN")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "FOO")
               " ("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "A")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "B")
               ")"
               #\Newline
               "  ("
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "LIST")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "A")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "B")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "C")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "D")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "E")
               " "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "F")
               #\Newline
               "    "
               (:fg lustre-tests/color-sexp:+default-symbol-color+ "G")
               "))")
     (lustre-tests/color-sexp:color-sexp-to-string
      '(defun foo (a b) (list a b c d e f g))
      (find-package :lustre-tests/color-sexp/tests)))))

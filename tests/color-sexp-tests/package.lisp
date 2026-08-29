(defpackage lustre-tests/color-sexp/tests
  (:documentation "lustre-tests/color-sexp tests.")
  (:use #:cl)
  (:local-nicknames
   (#:lt #:lustre-tests)
   (#:cs #:lustre-tests/color-sexp)))

(in-package #:lustre-tests/color-sexp/tests)

(defmacro ansi-seq (&rest body)
  (let ((transformed-body
          (loop for exp in body
                collect (etypecase exp
                          ((or string character) `(format out "~A" ,exp))
                          (list `(ansi:format-ansi out (list (list ,@exp))))))))
    `(with-output-to-string (out) ,@transformed-body)))

(defpackage my-symbols
  (:export #:foo))

(lt:define-test colors-symbol (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg cs:+default-symbol-color+ "MY-SYMBOLS:FOO") ")")
   (cs:color-sexp-to-string '(my-symbols:foo))))

(lt:define-test colors-numbers (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg cs:+default-number-color+ "10") ")")
   (cs:color-sexp-to-string '(10))))

(lt:define-test colors-keywords (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg cs:+default-keyword-color+ ":HELLO") ")")
   (cs:color-sexp-to-string '(:hello))))

(lt:define-test colors-special-operators (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg cs:+default-special-operator-color+ "FUNCTION") ")")
   (cs:color-sexp-to-string '(function))))

(lt:define-test colors-chars-and-strings (color-sexp)
  (lt:expect-seq
   (ansi-seq "("
             (:fg cs:+default-char-color+ "#\\A")
             " "
             (:fg cs:+default-string-color+ "\"Joe\"")
             ")")
   (cs:color-sexp-to-string '(#\A "Joe"))))

(lt:define-test colors-standard-macros (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg cs:+default-standard-macro-color+ "DEFUN") ")")
   (cs:color-sexp-to-string '(defun))))

(lt:define-test colors-lambda-list-keywords (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg cs:+default-lambda-list-keyword-color+ "&OPTIONAL") ")")
   (cs:color-sexp-to-string '(&optional))))

(lt:define-test colors-full-expression (color-sexp)
  (lt:expect-seq
   (ansi-seq "("
             (:fg cs:+default-standard-macro-color+ "DEFUN")
             " "
             (:fg cs:+default-keyword-color+ ":MY-FUN")
             " ("
             (:fg cs:+default-symbol-color+ "ARG")
             " "
             (:fg cs:+default-lambda-list-keyword-color+ "&KEY")
             " "
             (:fg cs:+default-symbol-color+ "K1")
             ") "
             (:fg cs:+default-string-color+ "\"My function.\"")
             " ("
             (:fg cs:+default-special-operator-color+ "LET")
             " (("
             (:fg cs:+default-symbol-color+ "X")
             " "
             (:fg cs:+default-char-color+ "#\\A")
             ")) ("
             (:fg cs:+default-standard-macro-color+ "DOLIST")
             " ("
             (:fg cs:+default-symbol-color+ "ITEM")
             " "
             (:fg cs:+default-symbol-color+ "K1")
             ") ("
             (:fg cs:+default-symbol-color+ "FORMAT")
             " "
             (:fg cs:+default-symbol-color+ "T")
             " "
             (:fg cs:+default-symbol-color+ "STR")
             " "
             (:fg cs:+default-symbol-color+ "ARG")
             " ("             
             (:fg cs:+default-symbol-color+ "Y")
             " "
             (:fg cs:+default-number-color+ "2")
             " "
             (:fg cs:+default-symbol-color+ "X")
             " "
             (:fg cs:+default-symbol-color+ "ITEM")
             ")))))")
   (cs:color-sexp-to-string
    '(defun :my-fun (arg &key k1)
      "My function."
      (let ((x #\A))
        (dolist (item k1) (format T "STR" arg (y 2 x item))))))))
  

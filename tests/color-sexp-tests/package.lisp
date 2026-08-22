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
                          (list `(ansi:format-ansi out (list ',exp)))))))
    `(with-output-to-string (out) ,@transformed-body)))

(defpackage my-symbols
  (:export #:foo))

(lt:define-test colors-symbol (color-sexp)
  (lt:expect-seq
   (ansi-seq "(" (:fg :cyan "MY-SYMBOLS:FOO") ")")
   (cs:color-sexp-to-string '(my-symbols:foo))))

(lt:define-test temp-test (color-sexp)
  (lt:expect-seq
   '(1 2 3)
   '(1 2 3)))

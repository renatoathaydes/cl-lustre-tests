(defpackage lustre-tests/color-sexp/tests
  (:documentation "lustre-tests/color-sexp tests.")
  (:use #:cl)
  (:local-nicknames
   (#:lt #:lustre-tests)
   (#:cs #:lustre-tests/color-sexp)))

(in-package #:lustre-tests/color-sexp/tests)

(lt:define-test colors-symbol (color-sexp)
  (lt:expect-seq
   (ansi:format-ansi nil '("(" (:fg :cyan "foo") ")"))
   (cs:color-sexp-to-string '(foo))))

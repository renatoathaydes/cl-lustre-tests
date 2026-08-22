(defpackage lustre-tests/color-sexp/tests
  (:documentation "lustre-tests/color-sexp tests.")
  (:use #:cl
        #:lustre-tests
        #:lustre-tests/color-sexp))

(in-package #:lustre-tests/color-sexp/tests)

(define-test colors-symbol (color-sexp)
  (expect-seq
   (ansi:format-ansi nil '("(" (:fg :cyan "foo") ")"))
   (color-sexp-to-string '(foo))))

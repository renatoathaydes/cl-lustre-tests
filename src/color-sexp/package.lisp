(defpackage #:lustre-tests/color-sexp
  (:use #:cl)
  (:documentation "Helper package for cl-lustre-tests to be able to display S-expressions in color.")
  (:export #:color-sexp
           #:*symbol-color*
           #:*string-color*
           #:*char-color*
           #:*number-color*))

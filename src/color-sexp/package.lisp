(defpackage #:lustre-tests/color-sexp
  (:use #:cl)
  (:documentation "Helper package for cl-lustre-tests to be able to display S-expressions in color.")
  (:export #:color-sexp
           #:color-sexp-to-string
           #:*string-color*
           #:*char-color*
           #:*number-color*
           #:*keyword-color*
           #:*symbol-color*
           #:*special-operator-color*
           #:*standard-macro-color*
           #:*lambda-list-keyword-color*
           #:+default-color+
           #:+default-string-color+
           #:+default-char-color+
           #:+default-number-color+
           #:+default-keyword-color+
           #:+default-symbol-color+
           #:+default-special-operator-color+
           #:+default-standard-macro-color+
           #:+default-lambda-list-keyword-color+))

(in-package #:lustre-tests)

;; all lustre-tests special-variables that a new thread needs to inherit.
(defun all-special-vars ()
  `((lustre-tests/color-sexp:*string-color* . ,lustre-tests/color-sexp:*string-color*)
    (lustre-tests/color-sexp:*char-color* . ,lustre-tests/color-sexp:*char-color*)
    (lustre-tests/color-sexp:*number-color* . ,lustre-tests/color-sexp:*number-color*)
    (lustre-tests/color-sexp:*keyword-color* . ,lustre-tests/color-sexp:*keyword-color*)
    (lustre-tests/color-sexp:*symbol-color* . ,lustre-tests/color-sexp:*symbol-color*)
    (lustre-tests/color-sexp:*special-operator-color* . ,lustre-tests/color-sexp:*special-operator-color*)
    (lustre-tests/color-sexp:*standard-macro-color* . ,lustre-tests/color-sexp:*standard-macro-color*)
    (lustre-tests/color-sexp:*lambda-list-keyword-color* . ,lustre-tests/color-sexp:*lambda-list-keyword-color*)
    (lustre-tests/color-sexp:*sexp-line-limit* . ,lustre-tests/color-sexp:*sexp-line-limit*)
    (lustre-tests/time:*internal-time-units-per-sec* . lustre-tests/time:*internal-time-units-per-sec*)
    (*max-diff-items-to-display* . ,*max-diff-items-to-display*)
    (*max-displayed-items-before-diff* . ,*max-displayed-items-before-diff*)
    (*show-diff-with-ansi-colors* . ,*show-diff-with-ansi-colors*)
    ,@bt2:*default-special-bindings*))

(defun make-thread-with-bindings (function &key name)
  "Create a Bordeaux Thread that inherits all the special variables defined
by the Lustre-Tests library."
  (let ((bt2:*default-special-bindings* (all-special-vars)))
    (bt2:make-thread function :name name)))

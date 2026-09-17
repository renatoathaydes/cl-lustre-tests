(in-package #:lustre-tests)

;; all lustre-tests special-variables that a new thread needs to inherit.
(defun all-special-vars ()
  `((cs:*string-color* . ,cs:*string-color*)
    (cs:*char-color* . ,cs:*char-color*)
    (cs:*number-color* . ,cs:*number-color*)
    (cs:*keyword-color* . ,cs:*keyword-color*)
    (cs:*symbol-color* . ,cs:*symbol-color*)
    (cs:*special-operator-color* . ,cs:*special-operator-color*)
    (cs:*standard-macro-color* . ,cs:*standard-macro-color*)
    (cs:*lambda-list-keyword-color* . ,cs:*lambda-list-keyword-color*)
    (time:*internal-time-units-per-sec* . time:*internal-time-units-per-sec*)
    (*max-diff-items-to-display* . ,*max-diff-items-to-display*)
    (*max-displayed-items-before-diff* . ,*max-displayed-items-before-diff*)
    (*show-diff-with-ansi-colors* . ,*show-diff-with-ansi-colors*)
    ,@bt:*default-special-bindings*))

(defun make-thread-with-bindings (function &key name)
  "Create a Bordeaux Thread that inherits all the special variables defined
by the Lustre-Tests library."
  (let ((bt:*default-special-bindings* (all-special-vars)))
    (bt:make-thread function :name name)))

;;; cl-lustre-tests.asd
;;;
;;; SPDX-License-Identifier: MIT
;;;
;;; Copyright (C) 2026 Renato Athaydes

(asdf:defsystem #:cl-lustre-tests
  :description "A basic application."
  :author      "Renato Athaydes"
  :license     "MIT"
  :version     "0.1.0"
  :depends-on  ("format-ansi")
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "main" :depends-on ("package"))))

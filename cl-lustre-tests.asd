;;; cl-lustre-tests.asd
;;;
;;; SPDX-License-Identifier: MIT
;;;
;;; Copyright (C) 2026 Renato Athaydes

(asdf:defsystem #:cl-lustre-tests
  :description "A simple testing framework that focuses on usability and great reporting."
  :author      "Renato Athaydes"
  :license     "MIT"
  :version     "0.1.0"
  :depends-on  ("format-ansi")
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "protocol" :depends-on ("package"))
               (:file "test-result" :depends-on ("protocol"))
               (:file "test-instance" :depends-on ("protocol"))
               (:file "test-parent" :depends-on ("test-instance"))
               (:file "test-reporter" :depends-on ("protocol"))
               (:file "test-sequencer" :depends-on ("protocol"))
               (:file "main" :depends-on ("test-reporter" "test-sequencer"))))

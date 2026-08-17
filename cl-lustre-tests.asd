
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
  :pathname "src"
  :components ((:file "package")
               (:file "protocol" :depends-on ("package"))
               (:file "test-result" :depends-on ("protocol"))
               (:file "test-instance" :depends-on ("protocol"))
               (:file "test-parent" :depends-on ("test-instance"))
               (:file "test-reporter" :depends-on ("protocol"))
               (:file "test-sequencer" :depends-on ("protocol"))
               (:file "main" :depends-on ("test-reporter" "test-sequencer")))
  :in-order-to ((asdf:test-op (asdf:test-op "cl-lustre-tests/tests"))))

(asdf:defsystem #:cl-lustre-tests/tests
  :description "Lustre Tests own tests."
  :author      "Renato Athaydes"
  :license     "MIT"
  :version     "0.1.0"
  :depends-on  ("format-ansi" "cl-lustre-tests")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "basic-test-framework")
               (:file "deftest-tests")
               (:file "end-to-end-tests")
               (:file "test-runner"))
  :perform (asdf:test-op (op c)
                         ;; on-error -> :condition | :print | :exit
                         (uiop:symbol-call :lustre-tests/tests :run-tests :on-error :exit)))

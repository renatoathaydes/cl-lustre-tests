
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
  :depends-on  ("alexandria"
                "format-ansi"
                "edit-distance"
                "trivial-gray-streams"
                "bordeaux-threads")
  :components ((:module "color-sexp"
                :pathname "src/color-sexp"
                :components ((:file "package")
                             (:file "core" :depends-on ("package"))))
               (:module "time"
                :pathname "src/time"
                :components ((:file "package")))
               (:module "src"
                :depends-on ("color-sexp" "time")
                :components ((:file "package")
                             (:file "protocol" :depends-on ("package"))
                             (:file "test-result" :depends-on ("protocol"))
                             (:file "simple-test" :depends-on ("protocol"))
                             (:file "test-parent" :depends-on ("protocol"))
                             (:file "test-reporter" :depends-on ("simple-test"))
                             (:file "test-sequencer" :depends-on ("protocol"))
                             (:file "expects" :depends-on ("simple-test"))
                             (:file "main" :depends-on ("test-reporter" "test-sequencer")))))
  :in-order-to ((asdf:test-op (asdf:test-op "cl-lustre-tests/tests"))))

(asdf:defsystem #:cl-lustre-tests/tests
  :description "Lustre Tests own tests."
  :author      "Renato Athaydes"
  :license     "MIT"
  :version     "0.1.0"
  :depends-on  ("format-ansi" "cl-lustre-tests")
  :pathname "tests"
  :components ((:module "test-helpers"
                :components ((:file "package")))
               (:module "basic-test-framework"
                :components ((:file "package")))
               (:module "color-sexp-tests"
                :depends-on ("test-helpers")
                :components ((:file "package")))
               (:module "time-tests"
                :components ((:file "package")))
               (:module "tests"
                :depends-on ("basic-test-framework" "test-helpers")
                :components ((:file "package")
                             (:file "define-test-tests" :depends-on ("package"))
                             (:file "parent-tests" :depends-on ("package"))
                             (:file "sequencer-tests" :depends-on ("package"))
                             (:file "simple-test-reporter-tests" :depends-on ("package"))
                             (:file "ansi-test-reporter-tests" :depends-on ("package"))
                             (:file "expect-seq-tests" :depends-on ("package"))
                             (:file "eval-test-tests" :depends-on ("package"))
                             (:file "end-to-end-tests" :depends-on ("package"))))
               (:module "runner"
                :depends-on ("tests")
                :components ((:file "package"))))
  :perform (asdf:test-op (op c)
                         ;; on-error -> :condition | :print | :exit
                         (uiop:symbol-call :lustre-tests/runner :run-tests :on-error :exit)))

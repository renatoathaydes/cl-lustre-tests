(in-package #:lustre-tests/tests)

(define-lustre-test report-successful-tests-correctly-by-default
  (with-local-root (root)
    (lt:define-test test-2+2=4 () (= (+ 2 2) 4))
    (lt:define-test test-string (string-tests) (string= (string #\A) "A"))
    (let ((result
            (with-output-to-string (stream)
              (lt:test :stream stream :test-parent root))))
      (lt:expect-seq
       (ansi:format-ansi
        nil
        `(("== LUSTRE TESTS ==~%")
          (:st :italic "Running 2 test(s).~%")
          ("") ;; separation between format-ansi calls in impl
          (:fg :green "OK: ")
          (:st :bold "TEST-2+2=4~%")
          ("")
          (:st :bold :fg :cyan "  >> STRING-TESTS~%")
          ("")
          (:fg :green "  OK: ")
          (:st :bold "TEST-STRING~%")
          ("")
          (:fg :green "Success: 2, ")
          (:fg :yellow "Failures: 0, ")
          (:fg :red "Errors: 0~%")))
       result))))

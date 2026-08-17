(in-package #:lustre-tests/tests)

(define-lustre-test report-successful-tests-correctly-by-default
  (let ((all-tests (make-instance 'lustre-tests:test-parent)))
    (lustre-tests:define-test test-2+2=4 (all-tests) (= (+ 2 2) 4))
    (lustre-tests:define-test test-string (all-tests) (string= (string #\A) "A"))
    (let ((result
            (with-output-to-string (stream)
              (lustre-tests:test :stream stream :test-parent all-tests))))
      (assert-strings-equal
       'report-successful-tests-correctly-by-default
       result
       (ansi:format-ansi
        nil
        `((:fg :green "== LUSTRE TESTS ==~%Running 2 test(s).~%")
          ("") ;; separation between format-ansi calls in impl
          (:fg :green "OK: ")
          (:st :bold "TEST-2+2=4~%")
          ("")
          (:fg :green "OK: ")
          (:st :bold "TEST-STRING~%")
          ("")
          (:fg :green "Success: 2, ")
          (:fg :yellow "Failures: 0, ")
          (:fg :red "Errors: 0~%")))))))

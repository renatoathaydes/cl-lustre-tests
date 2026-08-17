(in-package #:lustre-tests/tests)

(define-lustre-test report-successful-tests-correctly-by-default
    (let ((all-tests nil))
      (lustre-tests:deftest test-2+2=4 (all-tests) (= (+ 2 2) 4))
      (lustre-tests:deftest test-string (all-tests) (string= (string #\A) "A"))
      (let ((result
              (with-output-to-string (stream)
                (lustre-tests:test :stream stream :tests all-tests))))
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

;; TODO:
;;  - use define-test so emacs highlights it better
;;  - make test bodies actual functions so we can recompile tests more easily?


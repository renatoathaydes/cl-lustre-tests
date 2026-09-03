(in-package #:lustre-tests/tests)

(defmacro mock-time (&body body)
  `(let ((original-fn #'lustre-tests/time:print-time))
     (setf (symbol-function 'lustre-tests/time:print-time)
           (let ((count 0))
            (lambda (time st)
              (declare (ignore time))
              (princ (incf count) st))))
     (unwind-protect (progn ,@body)
       (setf (symbol-function 'lustre-tests/time:print-time) original-fn))))

(define-lustre-test report-successful-tests-correctly-simple
  (with-local-root (root)
    (in-package #:lustre-tests/tests) ;; fixes symbols for the test names below!
    (lt:define-test test-2+2=4 ()
      (assert (= (+ 2 2) 4)))
    (lt:define-test test-string (string-tests)
      (assert (string= (string #\A) "A")))
    (let ((result
            (with-output-to-string (stream)
              (mock-time
                (lt:test-simple :stream stream :test-parent root :parallel? nil)))))
      (lt:expect-seq "== LUSTRE TESTS ==
Running 2 test(s).
OK: LUSTRE-TESTS/TESTS::TEST-2+2=4 (1)
  >> STRING-TESTS
  OK: LUSTRE-TESTS/TESTS::TEST-STRING (2)
  << STRING-TESTS (3)
Success: 2, Ignored: 0, Failures: 0 (4)
"
                     result))))

(define-lustre-test report-successful-tests-correctly-by-default
  (with-local-root (root)
    (in-package #:lustre-tests/tests) ;; fixes symbols for the test names below!
    (lt:define-test test-2+2=4 ()
      (assert (= (+ 2 2) 4)))
    (lt:define-test test-string (string-tests)
      (assert (string= (string #\A) "A")))
    (let ((result
            (with-output-to-string (stream)
              (mock-time
                (lt:test :stream stream :test-parent root :parallel? nil)))))
      (lt:expect-seq
       (concatenate
        'string
        (ansi:format-ansi
         nil
         `(("== LUSTRE TESTS ==~%")
           (:st :italic "Running 2 test(s).~%")
           ("") ;; separation between format-ansi calls in impl
           (:fg :green "OK: ")
           (:st :bold "LUSTRE-TESTS/TESTS::TEST-2+2=4 ")
           ("(1)~%")
           (:st :bold :fg :cyan "  >> STRING-TESTS~%")
           ("")
           (:fg :green "  OK: ")
           (:st :bold "LUSTRE-TESTS/TESTS::TEST-STRING ")
           ("(2)~%")
           ("  ")
           (:st :bold :fg :cyan "<< STRING-TESTS ")
           ("(3)~%")
           (:fg :green "Success: 2, ")
           (:fg 8 "Ignored: 0, ")
           (:fg :red "Failures: 0 ")))
        (format nil "(4)~%"))
       result))))

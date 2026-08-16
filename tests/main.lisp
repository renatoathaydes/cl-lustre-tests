(in-package #:lustre-tests/tests)

;;;; Tiniest test framework in the world ;;;;

(defparameter *tests* nil)

(defmacro define-lustre-test (name &body body)
  `(progn
     (defun ,name () ,@body)
     (pushnew ',name *tests*)))

;;;; ACTUAL TESTS ;;;;

;; deftest tests

(define-lustre-test deftest-defines-test-globally-by-default ()
  (let ((lustre-tests::*tests* nil))
    (lustre-tests:deftest my-test () T)
    (assert (= 1 (length lustre-tests::*tests*)))))

(define-lustre-test deftest-can-define-test-locally ()
  (let ((local-tests nil))
    (lustre-tests:deftest my-test (local-tests) T)
    (assert (= 1 (length local-tests)))
    (assert (= 0 (length lustre-tests::*tests*)))))

;; end-to-end tests

(defun assert-strings-equal (test-name actual expected)
  (unless (string= expected actual)
    (error (with-output-to-string (s)
      (format s "~A FAILED~%" test-name)
      (format s "Expected: ~S~%" expected)
      (format s "Actual:   ~S~%" actual)
      (format s "Difference at position ~D:~%"
              (or (mismatch expected actual) (length expected)))))))

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
       (concatenate 'string
                    (ansi:format-ansi nil `((:fg :green "== LUSTRE TESTS ==~%Running 2 test(s).~%")
                                            ("") ;; separation between format-ansi calls in impl
                                            (:fg :green "OK: ")
                                            (:st :bold "TEST-2+2=4~%")
                                            ("")
                                            (:fg :green "OK: ")
                                            (:st :bold "TEST-STRING~%")))
                    "Success: 2, Failures: 0, Errors: 0"
                    '(#\NEWLINE))))))

;; TODO:
;;  - use define-test so emacs highlights it better
;;  - make test bodies actual functions so we can recompile tests more easily?

;;;; TEST RUNNER ;;;;

(defmacro run-test (name)
  `(handler-case (progn
                    (funcall ,name)
                    (incf success-count))
     (error (e)
       (incf error-count)
       (format T "ERROR: ~A~%  ~A~%" ',name e))))

(defun run-tests (&key (on-error :condition))
  "Run the tests.
The ERROR-MODE should be one of :condition | :print | :exit."
  (format T "Running Lustre Tests' own tests!~%")
  (let ((error-count 0)
        (success-count 0))
    (dolist (test *tests*)
      (run-test test))
    (if (zerop error-count)
        (ansi:format-ansi T `((:fg :green "OK - all ~A test(s) passed!~%" ,success-count)))
        (flet ((print-results ()
                 (ansi:format-ansi T `((:fg :red "Not OK: ~A error(s), ~A OK.~%" ,error-count ,success-count)))))
          (ecase on-error
            (:condition (error 'lustre-tests:test-error
                               :reason `(:success-count ,success-count :error-count ,error-count)))
            (:print (print-results))
            (:exit (print-results)
             (uiop:quit 1)))))))

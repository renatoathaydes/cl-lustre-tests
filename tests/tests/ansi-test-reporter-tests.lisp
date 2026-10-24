(in-package #:lustre-tests/tests)

(define-lustre-test ansi-test-reporter-prints-test-ok
  (let* ((reporter (make-instance 'lustre-tests:ansi-test-reporter))
         (parent (make-instance 'lustre-tests:test-parent
                                :name "P"
                                :result (make-instance 'lustre-tests:test-result)))
         (child (make-test-ok "C")))
    (lustre-tests::add-child child parent)
    (lustre-tests:expect-seq
     (concatenate 'string 
                  (ansi:format-ansi nil `(("== LUSTRE TESTS ==~%")
                                          (:st :italic "Running 1 test(s).~%")
                                          ("")
                                          (:fg :green "OK: ")
                                          (:st :bold "C ")
                                          ("(1)~%")
                                          (:fg :green "Success: 1, ")
                                          (:fg 8 "Ignored: 0, ")
                                          (:fg :red "Failures: 0 ")))
                  (format nil "(2)~%"))
     (with-output-to-string (stream)
       (mocking-print-time
         (let ((ctx (lustre-tests:report-start stream reporter parent nil)))
           (setf ctx (lustre-tests:report-start stream reporter child ctx))
           (setf ctx (lustre-tests:report-end stream reporter child ctx))
           (lustre-tests:report-end stream reporter parent ctx)))))))

(define-lustre-test ansi-test-reporter-prints-test-with-failure
  (let* ((reporter (make-instance 'lustre-tests:ansi-test-reporter))
         (parent (make-instance 'lustre-tests:test-parent
                                :name "P"
                                :result (make-instance 'lustre-tests:test-result)))
         (child (make-test-with-error "C" "big failure")))
    (lustre-tests::add-child child parent)
    (lustre-tests:expect-seq
     (concatenate 'string 
                  (ansi:format-ansi nil `(("== LUSTRE TESTS ==~%")
                                          (:st :italic "Running 1 test(s).~%")
                                          ("")
                                          (:fg :red "ERROR: ")
                                          (:fg :red :st :bold "C ")
                                          ("(1)~%=> big failure~%")
                                          (:fg :green "Success: 0, ")
                                          (:fg 8 "Ignored: 0, ")
                                          (:fg :red "Failures: 1 ")))
                  (format nil "(2)~%"))
     (with-output-to-string (stream)
       (mocking-print-time
         (let ((ctx (lustre-tests:report-start stream reporter parent nil)))
           (setf ctx (lustre-tests:report-start stream reporter child ctx))
           (setf ctx (lustre-tests:report-end stream reporter child ctx))
           (lustre-tests:report-end stream reporter parent ctx)))))))

(define-lustre-test ansi-test-reporter-prints-test-parents-ok
  (let* ((reporter (make-instance 'lustre-tests:ansi-test-reporter))
         (parent-1 (make-instance 'lustre-tests:test-parent
                                  :name "P1"
                                  :result (make-instance 'lustre-tests:test-result)))
         (parent-2 (make-instance 'lustre-tests:test-parent
                                  :name "P2"
                                  :result (make-instance 'lustre-tests:test-result)))
         (parent-3 (make-instance 'lustre-tests:test-parent
                                  :name "P3"
                                  :result (make-instance 'lustre-tests:test-result)))
         (child-1 (make-test-ok "C1"))
         (child-2 (make-test-ok "C2"))
         (child-3 (make-test-ok "C3"))
         (child-4 (make-test-ok "C4")))
    (lustre-tests::add-child parent-2 parent-1)
    (lustre-tests::add-child parent-3 parent-2)
    (lustre-tests::add-child child-1 parent-1)
    (lustre-tests::add-child child-2 parent-2)
    (lustre-tests::add-child child-3 parent-2)
    (lustre-tests::add-child child-4 parent-3)
    (lustre-tests:expect-seq
     (ansi-seq
      #\ESC
      "[0m== LUSTRE TESTS =="
      #\NEWLINE
      (:st :italic "Running 4 test(s).~%")
      ((:fg :green "OK: ")
       (:st :bold "C1 ")
       ("(1)~%")
       (:st :bold :fg :cyan "  >> P2~%"))
      ((:fg :green "  OK: ")
       (:st :bold "C2 ")
       ("(2)~%")
       (:fg :green "  OK: ")
       (:st :bold "C3 ")
       ("(3)~%")
       (:st :bold :fg :cyan "    >> P3~%"))
      ((:fg :green "    OK: ")
       (:st :bold "C4 ")
       ("(4)~%")
       ("    ")
       (:st :bold :fg :cyan "<< P3 ")
       ("(5)~%")
       ("  ")
       (:st :bold :fg :cyan "<< P2 ")
       ("(6)~%")
       (:fg :green "Success: 4, ")
       (:fg 8 "Ignored: 0, ")
       (:fg :red "Failures: 0 "))
      "(7)"
      #\NEWLINE)
     (with-output-to-string (stream)
       (mocking-print-time
         (let ((ctx (lustre-tests:report-start stream reporter parent-1 nil)))
           (setf ctx (lustre-tests:report-start stream reporter child-1 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-1 ctx))
           (setf ctx (lustre-tests:report-start stream reporter parent-2 ctx))
           (setf ctx (lustre-tests:report-start stream reporter child-2 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-2 ctx))
           (setf ctx (lustre-tests:report-start stream reporter child-3 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-3 ctx))
           (setf ctx (lustre-tests:report-start stream reporter parent-3 ctx))
           (setf ctx (lustre-tests:report-start stream reporter child-4 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-4 ctx))
           (setf ctx (lustre-tests:report-end stream reporter parent-3 ctx))
           (setf ctx (lustre-tests:report-end stream reporter parent-2 ctx))
           (lustre-tests:report-end stream reporter parent-1 ctx)))))))

(define-lustre-test ansi-test-reporter-prints-test-parents-with-errors
  (let* ((reporter (make-instance 'lustre-tests:ansi-test-reporter))
         (parent-1 (make-instance 'lustre-tests:test-parent
                                  :name "P1"
                                  :result (make-instance 'lustre-tests:test-result)))
         (parent-2 (make-instance 'lustre-tests:test-parent
                                  :name "P2"
                                  :result (make-instance 'lustre-tests:test-result)))
         (parent-3 (make-instance 'lustre-tests:test-parent
                                  :name "P3"
                                  :result (make-instance 'lustre-tests:test-result)))
         (child-1 (make-test-with-error "C1" "c1 failed"))
         (child-2 (make-test-ok "C2"))
         (child-3 (make-test-with-error "C3" "c3 failed"))
         (child-4 (make-test-ok "C4")))
    (lustre-tests::add-child parent-2 parent-1)
    (lustre-tests::add-child parent-3 parent-2)
    (lustre-tests::add-child child-1 parent-1)
    (lustre-tests::add-child child-2 parent-2)
    (lustre-tests::add-child child-3 parent-2)
    (lustre-tests::add-child child-4 parent-3)
    (lustre-tests:expect-seq
     (ansi-seq
      #\ESC
      "[0m== LUSTRE TESTS =="
      #\NEWLINE
      (:st :italic "Running 4 test(s).~%")
      ((:fg :red "ERROR: ")
       (:fg :red :st :bold "C1 ")
       ("(1)~%=> c1 failed~%")
       (:st :bold :fg :cyan "  >> P2~%"))
      ((:fg :green "  OK: ")
       (:st :bold "C2 ")
       ("(2)~%")
       (:fg :red "  ERROR: ")
       (:fg :red :st :bold "C3 ")
       ("(3)~%  => c3 failed~%")
       (:st :bold :fg :cyan "    >> P3~%"))
      ((:fg :green "    OK: ")
       (:st :bold "C4 ")
       ("(4)~%")
       ("    ")
       (:st :bold :fg :cyan "<< P3 ")
       ("(5)~%")
       ("  ")
       (:st :bold :fg :cyan "<< P2 ")
       ("(6)~%")
       (:fg :green "Success: 2, ")
       (:fg 8 "Ignored: 0, ")
       (:fg :red "Failures: 2 "))
      "(7)"
      #\NEWLINE)
     (with-output-to-string (stream)
       (mocking-print-time
         (let ((ctx (lustre-tests:report-start stream reporter parent-1 nil)))
           (setf ctx (lustre-tests:report-start stream reporter child-1 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-1 ctx))
           (setf ctx (lustre-tests:report-start stream reporter parent-2 ctx))
           (setf ctx (lustre-tests:report-start stream reporter child-2 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-2 ctx))
           (setf ctx (lustre-tests:report-start stream reporter child-3 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-3 ctx))
           (setf ctx (lustre-tests:report-start stream reporter parent-3 ctx))
           (setf ctx (lustre-tests:report-start stream reporter child-4 ctx))
           (setf ctx (lustre-tests:report-end stream reporter child-4 ctx))
           (setf ctx (lustre-tests:report-end stream reporter parent-3 ctx))
           (setf ctx (lustre-tests:report-end stream reporter parent-2 ctx))
           (lustre-tests:report-end stream reporter parent-1 ctx)))))))

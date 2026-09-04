(in-package #:lustre-tests/tests)

(define-lustre-test ansi-test-reporter-prints-test-ok
  (let* ((reporter (make-instance 'lt:ansi-test-reporter))
         (parent (make-instance 'lt:test-parent
                                :name "P"
                                :result (make-instance 'lt:test-result)))
         (child (make-test-ok "C")))
    (lt::add-child child parent)
    (lt:expect-seq
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
         (let ((ctx (lt:report-start stream reporter parent nil)))
           (lt:report-result stream reporter child ctx)
           (lt:report-end stream reporter parent ctx)))))))

(define-lustre-test ansi-test-reporter-prints-test-with-failure
  (let* ((reporter (make-instance 'lt:ansi-test-reporter))
         (parent (make-instance 'lt:test-parent
                                :name "P"
                                :result (make-instance 'lt:test-result)))
         (child (make-test-with-error "C" "big failure")))
    (lt::add-child child parent)
    (lt:expect-seq
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
         (let ((ctx (lt:report-start stream reporter parent nil)))
           (lt:report-result stream reporter child ctx)
           (lt:report-end stream reporter parent ctx)))))))

(define-lustre-test ansi-test-reporter-prints-test-parents-ok
  (let* ((reporter (make-instance 'lt:ansi-test-reporter))
         (parent-1 (make-instance 'lt:test-parent
                                  :name "P1"
                                  :result (make-instance 'lt:test-result)))
         (parent-2 (make-instance 'lt:test-parent
                                  :name "P2"
                                  :result (make-instance 'lt:test-result)))
         (parent-3 (make-instance 'lt:test-parent
                                  :name "P3"
                                  :result (make-instance 'lt:test-result)))
         (child-1 (make-test-ok "C1"))
         (child-2 (make-test-ok "C2"))
         (child-3 (make-test-ok "C3"))
         (child-4 (make-test-ok "C4")))
    (lt::add-child parent-2 parent-1)
    (lt::add-child parent-3 parent-2)
    (lt::add-child child-1 parent-1)
    (lt::add-child child-2 parent-2)
    (lt::add-child child-3 parent-2)
    (lt::add-child child-4 parent-3)
    (lt:expect-seq
     (concatenate 'string 
                  (ansi:format-ansi nil `(("== LUSTRE TESTS ==~%")
                                          (:st :italic "Running 4 test(s).~%")
                                          ("")
                                          (:fg :green "OK: ")
                                          (:st :bold "C1 ")
                                          ("(1)~%")
                                          (:st :bold :fg :cyan "  >> P2~%")
                                          (:fg :green "  OK: ")
                                          (:st :bold "C2 ")
                                          ("(2)~%")                                          
                                          (:fg :green "  OK: ")
                                          (:st :bold "C3 ")
                                          ("(3)~%")
                                          (:st :bold :fg :cyan "    >> P3~%")
                                          (:fg :green "  OK: ")
                                          (:st :bold "C4 ")
                                          ("(4)~%")
                                          (:st :bold :fg :cyan "    << P3 ")
                                          ("(5)~%")
                                          (:st :bold :fg :cyan "  << P2 ")
                                          ("(6)~%")
                                          (:fg :green "Success: 4, ")
                                          (:fg 8 "Ignored: 0, ")
                                          (:fg :red "Failures: 0 ")))
                  (format nil "(7)~%"))
     (with-output-to-string (stream)
       (mocking-print-time
         (let ((ctx (lt:report-start stream reporter parent-1 nil)))
           (lt:report-result stream reporter child-1 ctx)
           (setf ctx (lt:report-start stream reporter parent-2 ctx))
           (lt:report-result stream reporter child-2 ctx)
           (lt:report-result stream reporter child-3 ctx)
           (setf ctx (lt:report-start stream reporter parent-3 ctx))
           (lt:report-result stream reporter child-4 ctx)
           (setf ctx (lt:report-end stream reporter parent-3 ctx))
           (setf ctx (lt:report-end stream reporter parent-2 ctx))
           (lt:report-end stream reporter parent-1 ctx)))))))

(define-lustre-test ansi-test-reporter-prints-test-parents-with-errors
  (let* ((reporter (make-instance 'lt:ansi-test-reporter))
         (parent-1 (make-instance 'lt:test-parent
                                  :name "P1"
                                  :result (make-instance 'lt:test-result)))
         (parent-2 (make-instance 'lt:test-parent
                                  :name "P2"
                                  :result (make-instance 'lt:test-result)))
         (parent-3 (make-instance 'lt:test-parent
                                  :name "P3"
                                  :result (make-instance 'lt:test-result)))
         (child-1 (make-test-with-error "C1" "c1 failed"))
         (child-2 (make-test-ok "C2"))
         (child-3 (make-test-with-error "C3" "c3 failed"))
         (child-4 (make-test-ok "C4")))
    (lt::add-child parent-2 parent-1)
    (lt::add-child parent-3 parent-2)
    (lt::add-child child-1 parent-1)
    (lt::add-child child-2 parent-2)
    (lt::add-child child-3 parent-2)
    (lt::add-child child-4 parent-3)
    (lt:expect-seq
     (concatenate 'string 
                  (ansi:format-ansi nil `(("== LUSTRE TESTS ==~%")
                                          (:st :italic "Running 4 test(s).~%")
                                          ("")
                                          (:fg :red "ERROR: ")
                                          (:fg :red :st :bold "C1 ")
                                          ("(1)~%=> c1 failed~%")
                                          (:st :bold :fg :cyan "  >> P2~%")
                                          (:fg :green "  OK: ")
                                          (:st :bold "C2 ")
                                          ("(2)~%")
                                          (:fg :red "ERROR: ")
                                          (:fg :red :st :bold "C3 ")
                                          ("(3)~%=> c3 failed~%    ")
                                          (:fg :cyan ">> P3")
                                          ("    ")
                                          (:fg :green "OK: ")
                                          (:st :bold "C4 ")
                                          ("(4)~%    ")
                                          (:fg :cyan "<< P3")
                                          ("(5)~%  ")
                                          (:fg :cyan "<< P2")
                                          ("(6)~%")
                                          (:fg :green "Success: 2, ")
                                          (:fg 8 "Ignored: 0, ")
                                          (:fg :red "Failures: 2 ")))
                  (format nil "(7)~%"))
     (with-output-to-string (stream)
       (mocking-print-time
         (let ((ctx (lt:report-start stream reporter parent-1 nil)))
           (lt:report-result stream reporter child-1 ctx)
           (setf ctx (lt:report-start stream reporter parent-2 ctx))
           (lt:report-result stream reporter child-2 ctx)
           (lt:report-result stream reporter child-3 ctx)
           (setf ctx (lt:report-start stream reporter parent-3 ctx))
           (lt:report-result stream reporter child-4 ctx)
           (setf ctx (lt:report-end stream reporter parent-3 ctx))
           (setf ctx (lt:report-end stream reporter parent-2 ctx))
           (lt:report-end stream reporter parent-1 ctx)))))))

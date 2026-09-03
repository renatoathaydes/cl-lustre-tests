(in-package #:lustre-tests/tests)

(define-lustre-test simple-test-reporter-prints-test-ok
  (let* ((reporter (make-instance 'lt:simple-test-reporter))
         (parent (make-instance 'lt:test-parent
                                :name "P"
                                :result (make-instance 'lt:test-result)))
         (child (make-instance 'lt:test-object
                               :name "C"
                               :result (make-instance 'lt:test-result))))
    (lt::add-child child parent)
    (lt:expect-seq "== LUSTRE TESTS ==
Running 1 test(s).
OK: C (1)
Success: 1, Ignored: 0, Failures: 0 (2)
" (with-output-to-string (stream)
    (mocking-print-time
      (let ((ctx (lt:report-start stream reporter parent nil)))
        (lt:report-result stream reporter child ctx)
        (lt:report-end stream reporter parent ctx)))))))

(define-lustre-test simple-test-reporter-prints-test-with-failure
  (let* ((reporter (make-instance 'lt:simple-test-reporter))
         (parent (make-instance 'lt:test-parent
                                :name "P"
                                :result (make-instance 'lt:test-result)))
         (child (make-instance 'lt:test-object
                               :name "C"
                               :result (make-instance 'lt:test-result
                                                      :status :error
                                                      :description "big failure"))))
    (lt::add-child child parent)
    (lt:expect-seq "== LUSTRE TESTS ==
Running 1 test(s).
ERROR: C (1)
=> big failure
Success: 0, Ignored: 0, Failures: 1 (2)
" (with-output-to-string (stream)
    (mocking-print-time
      (let ((ctx (lt:report-start stream reporter parent nil)))
        (lt:report-result stream reporter child ctx)
        (lt:report-end stream reporter parent ctx)))))))

(define-lustre-test simple-test-reporter-prints-test-parents-ok
  (let* ((reporter (make-instance 'lt:simple-test-reporter))
         (parent-1 (make-instance 'lt:test-parent
                                  :name "P1"
                                  :result (make-instance 'lt:test-result)))
         (parent-2 (make-instance 'lt:test-parent
                                  :name "P2"
                                  :result (make-instance 'lt:test-result)))
         (parent-3 (make-instance 'lt:test-parent
                                  :name "P3"
                                  :result (make-instance 'lt:test-result)))
         (child-1 (make-instance 'lt:test-object
                                 :name "C1"
                                 :result (make-instance 'lt:test-result)))
         (child-2 (make-instance 'lt:test-object
                                 :name "C2"
                                 :result (make-instance 'lt:test-result)))
         (child-3 (make-instance 'lt:test-object
                                 :name "C3"
                                 :result (make-instance 'lt:test-result)))
         (child-4 (make-instance 'lt:test-object
                                 :name "C4"
                                 :result (make-instance 'lt:test-result))))
    (lt::add-child parent-2 parent-1)
    (lt::add-child parent-3 parent-2)
    (lt::add-child child-1 parent-1)
    (lt::add-child child-2 parent-2)
    (lt::add-child child-3 parent-2)
    (lt::add-child child-4 parent-3)
    (lt:expect-seq "== LUSTRE TESTS ==
Running 4 test(s).
OK: C1 (1)
  >> P2
  OK: C2 (2)
  OK: C3 (3)
    >> P3
    OK: C4 (4)
    << P3 (5)
  << P2 (6)
Success: 4, Ignored: 0, Failures: 0 (7)
" (with-output-to-string (stream)
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

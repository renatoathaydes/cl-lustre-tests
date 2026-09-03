(in-package #:lustre-tests/tests)

(define-lustre-test simple-test-reporter-prints-test-ok
  (let* ((reporter (make-instance 'lt:simple-test-reporter))
         (parent (make-instance 'lt:test-parent
                                :name "P"
                                :result (make-instance 'lt:test-result :status :ok)))
         (child (make-instance 'lt:test-object
                               :name "C"
                               :result (make-instance 'lt:test-result :status :ok))))
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
                                :result (make-instance 'lt:test-result :status :ok)))
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

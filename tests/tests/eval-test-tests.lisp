(in-package #:lustre-tests/tests)

(define-lustre-test eval-simple-test-ok-result
  (let ((test (make-instance 'lt:simple-test
                             :name "example test"
                             :fun (lambda ())
                             :body nil)))
    (lt:eval-test test)
    (let ((result (lt:test-result test)))
      (check-type result lt:simple-test-result)
      (assert (eq :ok (lt:test-result-status result))))))

(define-lustre-test eval-simple-test-fail-result
  (let ((test (make-instance 'lt:simple-test
                             :name "example test"
                             :fun (lambda () (error "no good"))
                             :body nil)))
    (let ((condition
            (handler-case (lt:eval-test test)
              (lt:test-error (c) c)
              (error (c) (error "Expected TEST-ERROR but got ~A" c)))))
      (check-type condition lt:test-error)
      (let ((result (lt:test-result test)))
        (check-type result lt:simple-test-result)
        (assert (eq :error (lt:test-result-status result)))
        (let ((desc (lt:test-result-description result)))
          (check-type desc simple-error)
          (lt:expect-seq "no good" (simple-condition-format-control desc)))))))

(define-lustre-test eval-simple-test-fails-but-ignored
  (let ((test (make-instance 'lt:simple-test
                             :name "example test"
                             :enabled nil
                             :fun (lambda () (error "no good"))
                             :body nil)))
    (lt:eval-test test)
    (let ((result (lt:test-result test)))
      (check-type result lt:simple-test-result)
      (assert (eq :ignored (lt:test-result-status result))))))

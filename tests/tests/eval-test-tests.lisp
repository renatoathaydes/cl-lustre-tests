(in-package #:lustre-tests/tests)

(define-lustre-test eval-simple-test-ok-result
  (let ((test (make-instance 'lustre-tests:simple-test
                             :name "example test"
                             :fun (lambda ())
                             :body nil)))
    (lustre-tests:eval-test test)
    (let ((result (lustre-tests:test-result test)))
      (check-type result lustre-tests:simple-test-result)
      (assert (eq :ok (lustre-tests:test-result-status result))))))

(define-lustre-test eval-simple-test-fail-result
  (let ((test (make-instance 'lustre-tests:simple-test
                             :name "example test"
                             :fun (lambda () (error "no good"))
                             :body nil)))
    (let ((condition
            (handler-case (lustre-tests:eval-test test)
              (lustre-tests:test-error (c) c)
              (error (c) (error "Expected TEST-ERROR but got ~A" c)))))
      (check-type condition lustre-tests:test-error)
      (let ((result (lustre-tests:test-result test)))
        (check-type result lustre-tests:simple-test-result)
        (assert (eq :error (lustre-tests:test-result-status result)))
        (let ((desc (lustre-tests:test-result-description result)))
          (check-type desc simple-error)
          (lustre-tests:expect-seq "no good" (simple-condition-format-control desc)))))))

(define-lustre-test eval-simple-test-fails-but-ignored
  (let ((test (make-instance 'lustre-tests:simple-test
                             :name "example test"
                             :enabled nil
                             :fun (lambda () (error "no good"))
                             :body nil)))
    (lustre-tests:eval-test test)
    (let ((result (lustre-tests:test-result test)))
      (check-type result lustre-tests:simple-test-result)
      (assert (eq :ignored (lustre-tests:test-result-status result))))))

(in-package #:lustre-tests/tests)

(define-lustre-test sequences-in-declaration-order-by-default
  (with-local-root (root)
    (lt:define-test t1 () T)
    (lt:define-test t2 () T)
    (lt:define-test t3 () T)
    (lt:define-test t4 () T)
    (lt:define-test final-test () T)
    (let* ((sequencer (make-instance 'lt:simple-test-sequencer))
           (result (lt:sequence-tests sequencer (lt:test-children root))))
      (assert (equalp (mapcar #'lt:test-name result)
                      '(t1 t2 t3 t4 final-test))))))

(define-lustre-test sequences-in-reverse-declaration-order
  (with-local-root (root)
    (lt:define-test t1 () T)
    (lt:define-test t2 () T)
    (lt:define-test t3 () T)
    (lt:define-test t4 () T)
    (lt:define-test final-test () T)
    (let* ((sequencer (make-instance 'lt:simple-test-sequencer
                                     :ordering :reverse-declaration-order))
           (result (lt:sequence-tests sequencer (lt:test-children root))))
      (assert (equalp (mapcar #'lt:test-name result)
                      '(final-test t4 t3 t2 t1))))))

(define-lustre-test sequences-in-random-order
  (with-local-root (root)
    (lt:define-test t1 () T)
    (lt:define-test t2 () T)
    (lt:define-test t3 () T)
    (lt:define-test t4 () T)
    (lt:define-test t5 () T)
    (lt:define-test t6 () T)
    (lt:define-test t7 () T)
    (lt:define-test t8 () T)
    (lt:define-test final-test () T)
    (flet ((do-sequence-tests ()
             (let* ((sequencer (make-instance 'lt:simple-test-sequencer
                                              :ordering :random))
                    (cl:*random-state* (make-random-state)))
               (mapcar #'lt:test-name
                       (lt:sequence-tests sequencer (lt:test-children root))))))
      (let ((r1 (do-sequence-tests))
            (r2 (do-sequence-tests)))
        (assert (equalp r1 r2))))))

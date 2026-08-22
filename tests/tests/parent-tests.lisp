(in-package #:lustre-tests/tests)

(define-lustre-test parent-can-add-and-find-tests
  (with-local-root (root)
    (lt:add-test (make-instance 'lt:test-object :name 'child-one) root)
    (assert (= 1 (length (lt:test-children root))))
    (assert (lt:find-test 'child-one root))
    (assert (not (lt:find-test 'child-two root)))))

(define-lustre-test parent-can-add-and-find-single-nested-tests
  (with-local-root (root)
    (lt:add-test (make-instance 'lt:test-object :name 'child-one)
                 root '(parent-one))
    (assert (= 1 (length (lt:test-children root))))
    (assert (lt:find-test 'parent-one root))
    (assert (lt:find-test 'child-one root '(parent-one)))
    (assert (not (lt:find-test 'child-two root '(parent-one))))
    (assert (not (lt:find-test 'child-two root '(parent-two))))))

(define-lustre-test parent-can-add-and-find-double-nested-tests
  (with-local-root (root)
    (lt:add-test (make-instance 'lt:test-object :name 'child-one)
                 root '(parent-one parent-two))
    (assert (= 1 (length (lt:test-children root))))
    (assert (lt:find-test 'parent-one root))
    (assert (lt:find-test 'parent-two root '(parent-one)))
    (assert (lt:find-test 'child-one root '(parent-one parent-two)))
    (assert (not (lt:find-test 'child-two root '(parent-one parent-two))))
    (assert (not (lt:find-test 'child-two root '(parent-two))))))

(define-lustre-test parent-can-add-and-remove-tests
  (with-local-root (root)
    (assert-nil (lt:remove-test 'child-one root))
    (lt:add-test (make-instance 'lt:test-object :name 'child-one) root)
    (lt:add-test (make-instance 'lt:test-object :name 'child-two) root)
    (assert-t (lt:remove-test 'child-one root))
    (assert-nil (lt:find-test 'child-one root))
    (assert (lt:find-test 'child-two root))
    (assert-t (lt:remove-test 'child-two root))
    (assert-nil (lt:find-test 'child-two root))))

(define-lustre-test parent-can-add-and-remove-double-nested-tests
  (with-local-root (root)
    (lt:add-test (make-instance 'lt:test-object :name 'child-one)
                 root '(parent-one parent-two))
    (lt:add-test (make-instance 'lt:test-object :name 'child-two)
                 root '(parent-one))
    (assert (lt:find-test 'child-one
                          root '(parent-one parent-two)))
    (assert-t (lt:remove-test 'child-one
                              root '(parent-one parent-two)))
    (assert-nil (lt::remove-test 'child-one
                                 root '(parent-one parent-two)))
    (assert-t (lt:remove-test 'child-two
                              root '(parent-one)))
    (assert-nil (lt:remove-test 'child-two
                                root '(parent-one parent-two)))
    (assert-t (lt::remove-test 'parent-two
                               root '(parent-one)))
    (assert-nil (lt:remove-test 'child-two
                                root '(parent-one parent-two)))))

(define-lustre-test parent-can-count-tests
  (with-local-root (root)
    (assert (zerop (lt:count-tests root)))
    (lt:add-test (make-instance 'lt:test-object :name 'child-zero) root)
    (lt:add-test (make-instance 'lt:test-object :name 'child-one)
                 root '(parent-one parent-two))
    (lt:add-test (make-instance 'lt:test-object :name 'child-two)
                 root '(parent-one))
    (lt:add-test (make-instance 'lt:test-object :name 'child-three)
                 root '(parent-one parent-two))
    (assert (= 4 (lt:count-tests root)))
    (assert (= 3 (lt:count-tests (lt:find-test 'parent-one root))))
    (assert (= 2 (lt:count-tests (lt:find-test
                                  'parent-two
                                  root '(parent-one)))))))

(in-package #:lustre-tests/tests)

(define-lustre-test parent-can-add-and-find-tests
  (with-local-root (root)
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-one) root)
    (assert (= 1 (length (lustre-tests:test-children root))))
    (assert (lustre-tests:find-test 'child-one root))
    (assert (not (lustre-tests:find-test 'child-two root)))))

(define-lustre-test parent-can-add-and-find-single-nested-tests
  (with-local-root (root)
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-one)
                           root '(parent-one))
    (assert (= 1 (length (lustre-tests:test-children root))))
    (assert (lustre-tests:find-test 'parent-one root))
    (assert (lustre-tests:find-test 'child-one root '(parent-one)))
    (assert (not (lustre-tests:find-test 'child-two root '(parent-one))))
    (assert (not (lustre-tests:find-test 'child-two root '(parent-two))))))

(define-lustre-test parent-can-add-and-find-double-nested-tests
  (with-local-root (root)
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-one)
                           root '(parent-one parent-two))
    (assert (= 1 (length (lustre-tests:test-children root))))
    (assert (lustre-tests:find-test 'parent-one root))
    (assert (lustre-tests:find-test 'parent-two root '(parent-one)))
    (assert (lustre-tests:find-test 'child-one root '(parent-one parent-two)))
    (assert (not (lustre-tests:find-test 'child-two root '(parent-one parent-two))))
    (assert (not (lustre-tests:find-test 'child-two root '(parent-two))))))

(define-lustre-test parent-can-add-and-remove-tests
  (with-local-root (root)
    (assert-nil (lustre-tests:remove-test 'child-one root))
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-one) root)
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-two) root)
    (assert-t (lustre-tests:remove-test 'child-one root))
    (assert-nil (lustre-tests:find-test 'child-one root))
    (assert (lustre-tests:find-test 'child-two root))
    (assert-t (lustre-tests:remove-test 'child-two root))
    (assert-nil (lustre-tests:find-test 'child-two root))))

(define-lustre-test parent-can-add-and-remove-double-nested-tests
  (with-local-root (root)
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-one)
                           root '(parent-one parent-two))
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-two)
                           root '(parent-one))
    (assert (lustre-tests:find-test 'child-one
                                    root '(parent-one parent-two)))
    (assert-t (lustre-tests:remove-test 'child-one
                                        root '(parent-one parent-two)))
    (assert-nil (lustre-tests::remove-test 'child-one
                                           root '(parent-one parent-two)))
    (assert-t (lustre-tests:remove-test 'child-two
                                        root '(parent-one)))
    (assert-nil (lustre-tests:remove-test 'child-two
                                          root '(parent-one parent-two)))
    (assert-t (lustre-tests::remove-test 'parent-two
                                         root '(parent-one)))
    (assert-nil (lustre-tests:remove-test 'child-two
                                          root '(parent-one parent-two)))))

(define-lustre-test parent-can-count-tests
  (with-local-root (root)
    (assert (zerop (lustre-tests:count-tests root)))
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-zero) root)
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-one)
                           root '(parent-one parent-two))
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-two)
                           root '(parent-one))
    (lustre-tests:add-test (make-instance 'lustre-tests:test-object :name 'child-three)
                           root '(parent-one parent-two))
    (assert (= 4 (lustre-tests:count-tests root)))
    (assert (= 3 (lustre-tests:count-tests (lustre-tests:find-test 'parent-one root))))
    (assert (= 2 (lustre-tests:count-tests (lustre-tests:find-test
                                            'parent-two
                                            root '(parent-one)))))))

(in-package #:lustre-tests/tests)

(defun assert-ok-result (result)
  (assert (eq result T)))

(defun assert-failed-description (result expected)
  (assert result)
  (assert (eq (lt:test-result-status result) :failed))
  (assert (string= (lt:test-result-description result) expected)))

(define-lustre-test expect-seq-equal-seqs
  (assert-ok-result (lt:expect-seq "" "")))

(define-lustre-test expect-seq-not-equal-same-length
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "a" "b")
     "Levenshtein distance: 1, first diff at 0, showing from 0 to 1
Expected: a 
Actual:   b 
          ^
Changes:  #((SUBSTITUTION a b))")))

(define-lustre-test expect-seq-not-equal-first-shorter
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "a" "ab")
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 2
Expected: a 
Actual:   a b 
            ^
Changes:  #((INSERTION NIL b))")))

(define-lustre-test expect-seq-not-equal-first-longer
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "ab" "a")
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 2
Expected: a b 
Actual:   a 
            ^
Changes:  #((DELETION b NIL))")))

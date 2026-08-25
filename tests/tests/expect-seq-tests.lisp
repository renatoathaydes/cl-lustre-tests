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
          ~")))

(define-lustre-test expect-seq-not-equal-first-shorter
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "a" "ab")
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 2
Expected: a
Actual:   a b
            +")))

(define-lustre-test expect-seq-not-equal-first-longer
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "ab" "a")
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 2
Expected: a b
Actual:   a
            -")))

(define-lustre-test expect-seq-not-equal-same-length-too-long-to-show-start
  (let ((lustre-tests::*max-diff-items-to-display* 4)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "abcde" "abcfe")
     "Levenshtein distance: 1, first diff at 3, showing from 1 to 5
Expected: ...b c d e
Actual:   ...b c f e
                 ~ ")))

(define-lustre-test expect-seq-not-equal-same-length-too-long-to-show-end
  (let ((lustre-tests::*max-diff-items-to-display* 4)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "abcde" "axcde")
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 4
Expected: a b c d...
Actual:   a x c d...
            ~   ")))

(define-lustre-test expect-seq-not-equal-same-length-too-long-to-show-start-end
  (let ((lustre-tests::*max-diff-items-to-display* 4)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "abcdefgh" "abcdxfgh")
     "Levenshtein distance: 1, first diff at 4, showing from 2 to 6
Expected: ...c d e f...
Actual:   ...c d x f...
                 ~ ")))

(define-lustre-test expect-seq-not-equal-deletions-and-substitutions
  (let ((lustre-tests::*max-diff-items-to-display* 5)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq "abcdefgh" "abcdfxh")
     "Levenshtein distance: 2, first diff at 4, showing from 2 to 7
Expected: ...c d e f g...
Actual:   ...c d   f x 
                 -   ~ ")))

(define-lustre-test expect-seq-not-equal-includes-invisible-characters
  (let ((lustre-tests::*max-diff-items-to-display* 6)
        (lustre-tests::*max-displayed-items-before-diff* 3))
    (flet ((conc (s1 char s2)
             (concatenate 'string s1 (string char) s2)))
      (assert-failed-description
       (lustre-tests:expect-seq (conc "abcd" #\ESC "efgh") (conc "abcd" #\ESC "fxhi"))
       "Levenshtein distance: 3, first diff at 5, showing from 2 to 8
Expected: ...c d \\x1B e f g...
Actual:   ...c d \\x1B   f x ...
                      -   ~ "))))

;;; SAME TESTS REPEATED FOR INTEGER SEQUENCES WITH MEMBERS HAVING MORE THAN ONE DIGIT

(define-lustre-test expect-seq-not-equal-same-length-ints
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq #(10) #(11))
     "Levenshtein distance: 1, first diff at 0, showing from 0 to 1
Expected: 10
Actual:   11
          ~")))

(define-lustre-test expect-seq-not-equal-first-shorter-ints
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq #(10) #(10 11))
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 2
Expected: 10
Actual:   10 11
             +")))

(define-lustre-test expect-seq-not-equal-first-longer-ints
  (let ((lustre-tests::*max-diff-items-to-display* 3)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq #(10 11) #(10))
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 2
Expected: 10 11
Actual:   10
             -")))

(define-lustre-test expect-seq-not-equal-same-length-too-long-to-show-start-ints
  (let ((lustre-tests::*max-diff-items-to-display* 4)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq #(10 11 12 13 14) #(10 11 12 66 14))
     "Levenshtein distance: 1, first diff at 3, showing from 1 to 5
Expected: ...11 12 13 14
Actual:   ...11 12 66 14
                   ~  ")))

(define-lustre-test expect-seq-not-equal-same-length-too-long-to-show-end-ints
  (let ((lustre-tests::*max-diff-items-to-display* 4)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq #(10 11 12 13 14) #(10 66 12 13 14))
     "Levenshtein distance: 1, first diff at 1, showing from 0 to 4
Expected: 10 11 12 13...
Actual:   10 66 12 13...
             ~     ")))

(define-lustre-test expect-seq-not-equal-same-length-too-long-to-show-start-end-ints
  (let ((lustre-tests::*max-diff-items-to-display* 4)
        (lustre-tests::*max-displayed-items-before-diff* 2))
    (assert-failed-description
     (lustre-tests:expect-seq #(10 11 12 13 14 15 16 17) '(10 11 12 13 66 15 16 17))
     "Levenshtein distance: 1, first diff at 4, showing from 2 to 6
Expected: ...12 13 14 15...
Actual:   ...12 13 66 15...
                   ~  ")))

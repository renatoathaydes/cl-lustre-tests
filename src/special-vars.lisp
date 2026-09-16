(in-package #:lustre-tests)

(defparameter *max-diff-items-to-display* 64
  "The maximum number of individual element matches to display
when EXPECT-SEQ fails, starting from the first element mismatch.")

(defparameter *max-displayed-items-before-diff* 20
  "The maximum number of items in a sequence to show before the diff starts")

(defparameter *show-diff-with-ansi-colors* nil
  "Whether to show diffs using ANSI colors.")

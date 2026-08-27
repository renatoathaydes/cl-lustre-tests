(defpackage #:lustre-tests
  (:use #:cl)
  (:documentation "The cl-lustre-tests package.")
  (:import-from #:trivial-gray-streams
                #:fundamental-character-output-stream)
  (:export #:test
           #:test-simple
           #:define-test
           #:make-test-name
           #:test-object
           #:test-result
           #:test-reporter
           #:test-sequencer
           #:test-parent
           #:add-test
           #:find-test
           #:remove-test
           #:print-test-tree
           #:count-tests
           #:dotests
           #:eval-test
           #:sequence-tests
           #:sequence-parents
           #:report-start
           #:report-result
           #:report-end
           #:simple-test-result
           #:simple-test
           #:simple-test-sequencer
           #:counting-test-reporter
           #:simple-test-reporter
           #:ansi-test-reporter
           #:test-error
           #:expect-seq
           ;; test-result slots
           #:test-result-status
           ;; simple-test-result slots
           #:test-result-description
           ;; test-parent slots
           #:test-children
           ;; test-object slots
           #:test-name
           #:test-enabled?
           ;; ansi-test-reporter slots
           #:ansi-enabled?
           ;; simple-test-sequencer slots
           #:test-sequence-ordering
           ;; expect-seq configuration
           #:*max-diff-items-to-display*
           #:*max-displayed-items-before-diff*
           #:*show-diff-with-ansi-colors*))

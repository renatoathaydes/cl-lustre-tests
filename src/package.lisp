(defpackage #:lustre-tests
  (:use #:cl)
  (:documentation "The lustre-tests core package.")
  (:import-from #:trivial-gray-streams
                #:fundamental-character-output-stream)
  (:local-nicknames (#:time #:lustre-tests/time))
  (:export #:test
           #:init-root
           #:clear-tests
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
           #:report-result-description
           #:report-end
           #:simple-test-result
           #:simple-test
           #:simple-test-sequencer
           #:counting-test-reporter
           #:simple-test-reporter
           #:ansi-test-reporter
           ;; conditions
           #:test-error
           #:test-done
           ;; test-error slots
           #:test-error-reason
           ;; test-done slots
           #:test-done-result
           ;; assertions
           #:expect-seq
           ;; test-result slots
           #:test-result-status
           ;; simple-test-result slots
           #:test-result-description
           ;; test-parent slots
           #:test-children
           ;; test-object slots
           #:test-name
           #:test-package
           #:test-enabled?
           ;; ansi-test-reporter slots
           #:ansi-enabled?
           ;; simple-test-sequencer slots
           #:test-sequence-ordering
           ;; expect-seq configuration
           #:*max-diff-items-to-display*
           #:*max-displayed-items-before-diff*
           #:*show-diff-with-ansi-colors*))

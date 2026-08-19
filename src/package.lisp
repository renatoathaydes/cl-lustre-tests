(defpackage #:lustre-tests
  (:use #:cl)
  (:documentation "The cl-lustre-tests package.")
  (:export #:test
           #:define-test
           #:make-test-name
           #:test-object
           #:test-result
           #:test-reporter
           #:test-sequencer
           #:test-parent
           #:add-test
           #:add-child
           #:find-child
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
           ;; test-result slots
           #:test-result-status
           ;; test-parent slots
           #:test-children
           ;; test-object slots
           #:test-name
           #:test-enabled?
           ;; ansi-test-reporter slots
           #:ansi-enabled?
           ;; simple-test-sequencer slots
           #:test-sequence-ordering))

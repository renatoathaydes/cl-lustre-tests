(defpackage #:lustre-tests
  (:use #:cl)
  (:documentation "The cl-lustre-tests package.")
  (:export #:test
           #:*root-test-parent*
           #:deftest
           #:test-object
           #:test-result
           #:test-reporter
           #:test-sequencer
           #:test-parent
           ;; functions and methods
           #:add-test
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
           #:test-enabled?
           ;; simple-test slots
           #:test-name
           ;; ansi-test-reporter slots
           #:ansi-enabled?
           ;; simple-test-sequencer slots
           #:test-sequence-ordering))

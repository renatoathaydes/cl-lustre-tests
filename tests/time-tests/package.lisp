(defpackage lustre-tests/time/tests
  (:documentation "lustre-tests/time.lisp tests.")
  (:use #:cl)
  (:local-nicknames
   (#:time #:lustre-tests/time)
   (#:lt #:lustre-tests)))

(in-package #:lustre-tests/time/tests)

(defun print-time-to-string (time)
  (with-output-to-string (s)
    (time:print-time time s)))

;; us resolution tests

(lt:define-test print-time-1-us (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "0.000001sec" (print-time-to-string 1))))

(lt:define-test print-time-1-ms (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "0.001sec" (print-time-to-string 1000))))

(lt:define-test print-time-1-sec (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "1sec" (print-time-to-string 1000000))))

(lt:define-test print-time-1-min (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "1min" (print-time-to-string (* 60 1000000)))))

(lt:define-test print-time-1-hour (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "1hr" (print-time-to-string (* 60 60 1000000)))))

(lt:define-test print-time-1-hour-1us (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "1hr, 1.000001sec" (print-time-to-string (1+ (* 60 60 1000000))))))

(lt:define-test print-time-1-hour-1ms (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "1hr, 1.001sec" (print-time-to-string (+ 1000 (* 60 60 1000000))))))

(lt:define-test print-time-with-all-units (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (string= "18hr, 45min, 1.234567sec" (print-time-to-string
                                         (+ 234567
                                            (* 45 60 1000000)
                                            (* 18 60 60 1000000))))))

;; ms resolution tests

(lt:define-test print-time-1-ms-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (string= "0.001sec" (print-time-to-string 1))))

(lt:define-test print-time-1-sec-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (string= "1sec" (print-time-to-string 1000))))

(lt:define-test print-time-1-min-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (string= "1min" (print-time-to-string (* 60 1000)))))

(lt:define-test print-time-1-hour-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (string= "1hr" (print-time-to-string (* 60 60 1000)))))

(lt:define-test print-time-1-hour-1ms-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (string= "1hr, 1.001sec" (print-time-to-string (1+ (* 60 60 1000))))))

(lt:define-test print-time-with-all-units-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (string= "24hr, 59min, 9.999sec" (print-time-to-string
                                      (+ 9999
                                         (* 59 60 1000)
                                         (* 24 60 60 1000))))))

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

(lt:define-test print-time-1-us (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1µs" (print-time-to-string 1)))))

(lt:define-test print-time-1-ms (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1ms" (print-time-to-string 1000)))))

(lt:define-test print-time-1-sec (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1sec" (print-time-to-string 1000000)))))

(lt:define-test print-time-1-min (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1min" (print-time-to-string (* 60 1000000))))))

(lt:define-test print-time-1-hour (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1hr" (print-time-to-string (* 60 60 1000000))))))

(lt:define-test print-time-1-hour-1us (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1hr, 1µs" (print-time-to-string (1+ (* 60 60 1000000)))))))

(lt:define-test print-time-1-hour-1ms (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "1hr, 1ms" (print-time-to-string (+ 1000 (* 60 60 1000000)))))))

(lt:define-test print-time-with-all-units (time)
  (let ((time:internal-time-units-per-sec 1000000))
    (assert (string= "18hr, 45min, 1sec, 234ms, 567µs"
                     (print-time-to-string
                      (+ (* 18 60 60 1000000)
                         (* 45 60 1000000)
                         1234567))))))

;; ms resolution tests

(lt:define-test print-time-1-ms-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (assert (string= "1ms" (print-time-to-string 1)))))

(lt:define-test print-time-1-sec-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (assert (string= "1sec" (print-time-to-string 1000)))))

(lt:define-test print-time-1-min-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (assert (string= "1min" (print-time-to-string (* 60 1000))))))

(lt:define-test print-time-1-hour-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (assert (string= "1hr" (print-time-to-string (* 60 60 1000))))))

(lt:define-test print-time-1-hour-1ms-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (assert (string= "1hr, 1ms" (print-time-to-string (1+ (* 60 60 1000)))))))

(lt:define-test print-time-with-all-units-at-ms-resolution (time)
  (let ((time:internal-time-units-per-sec 1000))
    (assert (string= "24hr, 59min, 9sec, 999ms"
                     (print-time-to-string
                      (+ (* 24 60 60 1000)
                         (* 59 60 1000)
                         9999))))))

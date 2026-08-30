(defpackage #:lustre-tests/time
  (:use #:cl)
  (:documentation "The lustre-tests time package.")
  (:export #:print-time
           #:internal-time-units-per-sec))

(in-package #:lustre-tests/time)

(defparameter internal-time-units-per-sec internal-time-units-per-second
  "Special copy of INTERNAL-TIME-UNITS-PER-SECOND to allow for LET overrides.")

(defun print-seconds (secs stream)
  (multiple-value-bind (hs fraction) (floor secs (* 60 60))
    (multiple-value-bind (mins s) (floor fraction 60)
      (let ((include-hs (> hs 0))
            (include-min (> mins 0))
            (include-sec (> s 0)))
        (when include-hs
          (format stream "~Dhr" hs))
        (when include-min
          (format stream "~A~Dmin" (if include-hs ", " "") mins))
        (when include-sec
          (format stream "~A~Dsec" (if (or include-hs include-min) ", " "") s))))))

(defun floorz (n d)
  "Same as floor, but if D is zero, return (VALUES 0 0)."
  (if (zerop d) (values 0 0)
      (floor n d)))

(defun print-time (time stream)
  "Print the given TIME in human-readable format.
The TIME should be in INTERNAL-TIME-UNITS-PER-SECOND.
Returns NIL (even if STREAM is NIL)."
  (if (zerop time)
      (write-string "0sec" stream)
      (let ((internal-time-units-per-millis (floor internal-time-units-per-sec 1000))
            (internal-time-units-per-micros (floor internal-time-units-per-sec 1000000)))
        (multiple-value-bind (secs fraction) (floor time internal-time-units-per-sec)
          (multiple-value-bind (ms fraction) (floorz fraction internal-time-units-per-millis)
            (let* ((us (floorz fraction internal-time-units-per-micros))
                   (include-sec (> secs 0))
                   (include-ms (> ms 0))
                   (include-us (> us 0)))
              (when include-sec (print-seconds secs stream))
              (when include-ms (format stream "~A~Dms" (if include-sec ", " "") ms))
              (when include-us (format stream "~A~Dµs" (if (or include-sec include-ms) ", " "") us)))))
        nil)))

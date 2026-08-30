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
      (when (> hs 0)
        (format stream "~Dhr, " hs))
      (when (> mins 0)
        (format stream "~Dmin, " mins))
      (format stream "~D" s))))

(defun floorz (n d)
  "Same as floor, but if D is zero, return (VALUES 0 0)."
  (if (zerop d) (values 0 0)
      (floor n d)))

(defun print-time (time stream)
  "Print the given TIME in human-readable format.
The TIME should be in INTERNAL-TIME-UNITS-PER-SECOND.
Returns NIL (even if STREAM is NIL)."
  (let ((internal-time-units-per-millis (floor internal-time-units-per-sec 1000))
        (internal-time-units-per-micros (floor internal-time-units-per-sec 1000000)))
    (multiple-value-bind (secs fraction) (floor time internal-time-units-per-sec)
      (multiple-value-bind (ms fraction) (floorz fraction internal-time-units-per-millis)
        (let ((us (floorz fraction internal-time-units-per-micros)))
          (print-seconds secs stream)
          (unless (and (zerop ms) (zerop us))
            (format stream ".~3,'0D" ms)
            (unless (zerop us)
              (format stream "~3,'0D" us)))
          (princ "sec" stream))))
    nil))

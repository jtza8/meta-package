; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :meta-package)

(defun nominate-external-symbols (package)
  (delete-if (complement #'classify-symbol)
             (sort (loop for symbol being each present-symbol in package
                         collect symbol)
                   #'string<)))

(defun list-external-symbols (package)
  (loop for symbol being each external-symbol in package
        collect symbol))

(internal two-difference)
(defun two-difference (less-than more-than subtrahends minuends)
  (setf subtrahends (sort subtrahends less-than)
        minuends (sort minuends less-than))
  (let ((minuend (pop minuends)) result)
    (dolist (subtrahend subtrahends result)
      again
      (cond ((null minuend) (push subtrahend result))
            ((funcall less-than subtrahend minuend)
             (push subtrahend result))
            ((funcall more-than subtrahend minuend) 
             (setf minuend (pop minuends))
             (go again))))))

(defun difference (less-than more-than &rest terms)
  (loop with subtrahend
        initially (setf subtrahend (pop terms))
        until (null terms)
        do (setf subtrahend 
                 (two-difference less-than more-than
                                 subtrahend (pop terms)))
        finally (return subtrahend)))

(defun calculate-external-symbols (package)
  (difference #'string< #'string> 
              (nominate-external-symbols package)
              (gethash (find-package package) *ignored-symbols*)))

(defmacro auto-export (package &key add-packages)
  `(export ',(union (delete-duplicates (apply #'append 
                                              (mapcar #'list-external-symbols
                                                      add-packages)))
                    (calculate-external-symbols package)
                    :test #'string=)
           ,package))
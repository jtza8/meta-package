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
(defun two-difference (less-than more-than subtrahend-list minuend-list)
  (let* ((subtrahends (sort subtrahend-list less-than))
         (minuends (sort minuend-list less-than))
         (minuend (pop minuends))
         (result '()))
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

(defmacro auto-export (package &rest forms)
  (flet ((add-external-symbols (packages)
           (delete-duplicates (apply #'nconc (mapcar #'list-external-symbols
                                                     packages)))))
    (multiple-value-bind (additives subtractives)
        (loop for form in forms
              if (eq (car form) :add-packages)
              collect (cadr form) into additives else
              if (eq (car form) :subtract-package)
              collect (cadr form) into subtractives
              else do (error "invalid mode ~s in AUTO-EXPORT" (car form))
              finally (return (values additives subtractives)))
      `(export ',(union (difference #'< #'>
                                    (add-external-symbols additives)
                                    (add-external-symbols subtractives))
                        (calculate-external-symbols package)
                        :test #'string=)
               ,package))))
; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :meta-package)

(defvar *internal-symbols* (make-hash-table))
(defvar *external-symbols* (make-hash-table))

(defun include-symbols (hash-table &rest symbols)
  (let ((symbol-list #1=(gethash *package* hash-table)))
    (if (null symbol-list)
        (setf #1# symbols)
        (setf #1# (union symbol-list symbols)))))

(defmacro internal (&rest symbols)
  `(apply #'include-symbols *internal-symbols* ',symbols))

(defmacro external (&rest symbols)
  `(apply #'include-symbols *external-symbols* ',symbols))

(internal *internal-symbols* *external-symbols* include-symbols 
          type-specifier-arglist with-symbol *type-specifier-arglists*
          classify-symbol)

(defun nominate-external-symbols (package)
  (delete-if (complement #'classify-symbol)
             (sort (loop for symbol being each present-symbol in package
                         collect symbol)
                   #'string<)))

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

(defmacro auto-export (package &key add-packages)
  (flet ((list-external-symbols (package)
            (loop for symbol being each external-symbol in package
               collect symbol)))
    `(export ',(union (delete-duplicates (apply #'append 
                                                (mapcar #'list-external-symbols
                                                        add-packages)))
                      (union (difference #'string< #'string> 
                                         (nominate-external-symbols package)
                                         (gethash (find-package package)
                                                  *internal-symbols*))
                             (gethash (find-package package)
                                      *external-symbols*)))
             ,package)))
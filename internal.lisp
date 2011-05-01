; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :meta-package)

(defparameter *ignored-symbols* (make-hash-table))

(defun ignore-symbols (&rest symbols)
  (let ((symbol-list #1=(gethash *package* *ignored-symbols*)))
    (if (null symbol-list)
        (setf #1# symbols)
        (setf #1# (union symbol-list symbols)))))

(defmacro internal (&rest symbols)
  `(apply #'ignore-symbols ',symbols))

(internal ignore-symbols *ignored-symbols* command-reader-macro)
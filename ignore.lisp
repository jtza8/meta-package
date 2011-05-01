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

(defun command-reader-macro (stream subchar args)
  (declare (ignore subchar args))
  (let* ((symbol-list (print (read stream)))
         (command (intern (symbol-name (pop symbol-list)) :meta-package)))
    (ecase command
      (internal `(ignore-symbols ',@symbol-list)))))

(set-dispatch-macro-character #\# #\@ #'command-reader-macro)
(ignore-symbols 'ignore-symbols '*ignored-symbols* 'command-reader-macro)
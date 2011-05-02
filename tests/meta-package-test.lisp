; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(defpackage meta-package-lab-rat
  (:use :cl :meta-package))
(in-package :meta-package-lab-rat)
(defparameter *symbol* :blah)
(defun foo () ())

(in-package :meta-package)

(defclass meta-package-test (test-case)
  ())

(defun matching-symbol-count (list-a list-b)
  (length (intersection list-a list-b)))

(def-test-method test-internal ((test meta-package-test))
  (setf *ignored-symbols* (make-hash-table))
  (ignore-symbols 'foo 'bar)
  (ignore-symbols 'baz)
  (assert-equal 3 (matching-symbol-count '(foo bar baz)
                                         #1=(gethash *package*
                                                     *ignored-symbols*)))
  (internal blah qux)
  (assert-equal 5 (matching-symbol-count '(bar baz foo blah qux) #1#)))

(def-test-method test-nominate-external-symbols ((test meta-package-test))
  (assert-equal 2 (matching-symbol-count
                     '(meta-package-lab-rat::*symbol* meta-package-lab-rat::foo)
                     (nominate-external-symbols :meta-package-lab-rat))))

(def-test-method test-difference ((test meta-package-test))
  (assert-equal 2 (matching-symbol-count '(2 4)
                   (difference #'< #'> '(1 2 3 4 5) '(1 3) '(5))))
  (assert-equal nil (difference #'< #'>)))

(def-test-method test-calculate-external-symbols ((test meta-package-test))
  (in-package :meta-package-lab-rat)
  (meta-package:internal *symbol*)
  (in-package :meta-package)
  (assert-equal '(meta-package-lab-rat::foo)
                (calculate-external-symbols :meta-package-lab-rat)))
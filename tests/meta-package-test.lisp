; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(defpackage meta-package-lab-rat
  (:use :cl))
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
  ())
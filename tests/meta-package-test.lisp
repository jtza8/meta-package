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

(def-test-method test-nominate-external-symbols ((test meta-package-test))
  (assert-equal 2 (matching-symbol-count
                     '(meta-package-lab-rat::*symbol* meta-package-lab-rat::foo)
                     (nominate-external-symbols :meta-package-lab-rat))))

(def-test-method test-difference ((test meta-package-test))
  (assert-equal 2 (matching-symbol-count '(2 4)
                   (difference #'< #'> '(1 2 3 4 5) '(1 3) '(5))))
  (assert-equal nil (difference #'< #'>)))

(def-test-method test-auto-export ((test meta-package-test))
  (in-package :meta-package-lab-rat)
  (internal *symbol*)
  (auto-export :meta-package-lab-rat)
  (in-package :meta-package)
  (assert-equal :internal
                (nth-value 1 (find-symbol "*SYMBOL*" :meta-package-lab-rat)))
  (assert-equal :external
                (nth-value 1 (find-symbol "FOO" :meta-package-lab-rat))))

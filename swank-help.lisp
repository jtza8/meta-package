; This was taken straight out of SWANK, which is in the Public Domain.
; I just adapted a few things but most of this is verbatim.  I would
; like to thank the authors of SWANK, whoever they might be... I also
; place whatever modifications I made in the Public Domain.

(in-package :meta-package)

(internal type-specifier-arglist)
(defgeneric type-specifier-arglist (typespec-operator)
  (:documentation
   "Return the argument list of the type specifier belonging to
TYPESPEC-OPERATOR.. If the arglist cannot be determined, the keyword
:NOT-AVAILABLE is returned.

The different SWANK backends can specialize this generic function to
include implementation-dependend declaration specifiers, or to provide
additional information on the specifiers defined in ANSI Common Lisp.")
  (:method (typespec-operator)
    (declare (special *type-specifier-arglists*)) ; defined at end of file.
    (typecase typespec-operator
      (symbol (or (cdr (assoc typespec-operator *type-specifier-arglists*))
                  :not-available))
      (t :not-available))))

(internal with-symbol)
(eval-when (:compile-toplevel)
  (defun with-symbol (name package)
    "Generate a form suitable for testing with #+."
    (if (and (find-package package)
             (find-symbol (string name) package))
        '(:and)
        '(:or))))

#+#.(meta-package::with-symbol 'deftype-lamda-list 'sb-introspect)
(defmethod type-specifier-arglist :around (typespec-operator)
  (multiple-value-bind (arglist foundp)
      (sb-introspect:deftype-lambda-list typespec-operator)
    (if foundp arglist (call-next-method))))

(defun classify-symbol (symbol)
  "Returns a list of classifiers that classify SYMBOL according to its
underneath objects (e.g. :BOUNDP if SYMBOL constitutes a special
variable.) The list may contain the following classification
keywords: :BOUNDP, :FBOUNDP, :CONSTANT, :GENERIC-FUNCTION,
:TYPESPEC, :CLASS, :MACRO, :SPECIAL-OPERATOR, and/or :PACKAGE"
  (check-type symbol symbol)
  (flet ((type-specifier-p (s)
           (or (documentation s 'type)
               (not (eq (type-specifier-arglist s) :not-available)))))
    (let (result)
      (when (boundp symbol)             (push (if (constantp symbol)
                                                  :constant :boundp) result))
      (when (fboundp symbol)            (push :fboundp result))
      (when (type-specifier-p symbol)   (push :typespec result))
      (when (find-class symbol nil)     (push :class result))
      (when (macro-function symbol)     (push :macro result))
      (when (special-operator-p symbol) (push :special-operator result))
      (when (find-package symbol)       (push :package result))
      (when (and (fboundp symbol)
                 (typep (ignore-errors (fdefinition symbol))
                        'generic-function))
        (push :generic-function result))

      result)))

(internal *type-specifier-arglists*)
(defparameter *type-specifier-arglists*
  '((and                . (&rest type-specifiers))
    (array              . (&optional element-type dimension-spec))
    (base-string        . (&optional size))
    (bit-vector         . (&optional size))
    (complex            . (&optional type-specifier))
    (cons               . (&optional car-typespec cdr-typespec))
    (double-float       . (&optional lower-limit upper-limit))
    (eql                . (object))
    (float              . (&optional lower-limit upper-limit))
    (function           . (&optional arg-typespec value-typespec))
    (integer            . (&optional lower-limit upper-limit))
    (long-float         . (&optional lower-limit upper-limit))
    (member             . (&rest eql-objects))
    (mod                . (n))
    (not                . (type-specifier))
    (or                 . (&rest type-specifiers))
    (rational           . (&optional lower-limit upper-limit))
    (real               . (&optional lower-limit upper-limit))
    (satisfies          . (predicate-symbol))
    (short-float        . (&optional lower-limit upper-limit))
    (signed-byte        . (&optional size))
    (simple-array       . (&optional element-type dimension-spec))
    (simple-base-string . (&optional size))
    (simple-bit-vector  . (&optional size))
    (simple-string      . (&optional size))
    (single-float       . (&optional lower-limit upper-limit))
    (simple-vector      . (&optional size))
    (string             . (&optional size))
    (unsigned-byte      . (&optional size))
    (values             . (&rest typespecs))
    (vector             . (&optional element-type size))
    ))

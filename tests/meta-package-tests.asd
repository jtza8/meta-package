(asdf:defsystem "meta-package-tests"
  :author "Jens Thiede"
  :depends-on ("meta-package" "xlunit")
  :serial t
  :components ((:file "package")
               (:file "meta-package-test")))
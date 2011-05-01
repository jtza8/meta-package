(asdf:defsystem "meta-package"
  :author "Jens Thiede"
  :license "BSD-Style"
  :serial t
  :components ((:file "package")
               (:file "internal")
               (:file "swank-help")
               (:file "meta-package")
               (:file "export")))
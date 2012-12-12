(defsystem list-site
  :depends-on ("ucg" "esrap" "cl-fad")
  :serial t
  :components ((:file "package")
	       (:file "utils")
	       (:file "database")
	       (:file "printer")
	       (:file "grammar")
	       (:file "object")
	       (:file "engine")))

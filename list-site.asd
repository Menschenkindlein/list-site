(defsystem list-site
  :depends-on ("ucg" "esrap" "cl-fad")
  :serial t
  :components ((:file "package")
	       (:file "utils")
	       (:file "database")
	       (:file "object")
	       (:file "grammar")
	       (:file "engine")))

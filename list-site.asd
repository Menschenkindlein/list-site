(defsystem list-site
  :depends-on ("ucg" "esrap" "cl-fad")
  :serial t
  :components ((:file "package")
	       (:file "utils")
	       (:file "database")
	       (:module "objects"
			:components ((:file "common")
				     (:file "author")
				     (:file "article")
				     (:file "style")
				     (:file "main")))
	       (:file "engine")
	       (:file "main")))

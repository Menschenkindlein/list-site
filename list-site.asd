(defsystem list-site
  :depends-on ("ucg" "esrap" "cl-fad")
  :serial t
  :components ((:file "package")
	       (:module "objects"
			:components ((:file "common")
				     (:file "author")
				     (:file "article")))
	       (:file "main")))

(in-package #:list-site)

;; Parser rules

;; (default-copy-grammar style)

(site-defrule style (* character)
  (:lambda (result)
    (text result)))

;; Printers rules

(add-html-structure 'style
		    (lambda (name body)
		      (let ((filename
			     (make-pathname
			      :directory
			      '(:relative "styles")
			      :name name
			      :type "css")))
			(let ((*local-root* "../")
			      (filename (merge-pathnames filename
							 *result-root*)))
			  (unless
			      (probe-file filename)
			    (ensure-directories-exist filename)
			    (with-open-file
				(file filename
				      :direction :output
				      :if-exists :error
				      :if-does-not-exist :create)
			      (format file (html body)))))
			(if *local-root*
			    (setf filename
				  (merge-pathnames
				   filename
				   *local-root*)))
			(format nil
				"<link type=\"text/css\" href=\"~a\" rel=\"stylesheet\">"
				filename))))
(in-package #:list-site)

;; Parser rules

(site-defrule author (* character)
  (:lambda (result)
    (list 'author-body (string-trim '(#\Newline) (text result)))))

(add-html-structure 'author
		    (lambda (name body)
		      (let ((filename
			     (merge-pathnames
			      (make-pathname
			       :directory
			       '(:relative "result" "authors")
			       :name name
			       :type "html")
			      *root*)))
			(unless
			    (probe-file filename)
			  (ensure-directories-exist filename)
			  (with-open-file
			      (file filename
				    :direction :output
				    :if-exists :error
				    :if-does-not-exist :create)
			    (format file (html body))))
			(format nil
				"<a href=\"~a\">~a</a>"
				filename
				(second body)))))

(add-html-structure 'author-body
		    (lambda (author-name)
		      (format nil
			      "~
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
  <head>
    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />
    <title>This is the personal page of ~a</title>
  </head>
  <body>
  <h1>~a is great!!!</h1>
  </body>
</html>"                      author-name author-name)))



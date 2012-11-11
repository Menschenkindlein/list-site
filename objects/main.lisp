(in-package #:list-site)

;; Parser rules

(site-defrule main (* character)
  (:lambda (result)
    (read-from-string (text result))))

;; Printers rules

(add-html-structure 'main
		    (lambda (name body)
		      (declare (ignore name))
		      (let ((filename
			     (make-pathname
			       :name "index"
			       :type "html")))
			(let ((*local-root* nil)
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
				"<a href=\"~a\">~a</a>"
				filename
				"Home page"))))

(add-html-structure 'main-body
		    (lambda (&rest vidgets)
		      (format nil
			      "~
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
  <head>
    ~a
    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />
    <title>Main page of the LIST SITE</title>
  </head>
  <body>
    <div id=\"body\">
      <h1>The LIST SITE</h1>
      <div class=\"vidgets\">
~{        ~a~^~%~}
      </div>
    </div>
  </body>
</html>"                      (html (get-item 'style "main"))
                              (mapcar #'html vidgets))))

(add-html-structure 'author-vidget
		    (lambda (author &optional (class "default"))
		      (format nil "<span class=\"~a\"><div class=\"author\">~
                                     <p>~a</p>~
                                   </div></span>"
			      class
			      (html (get-item 'author author)))))

(add-html-structure 'article-vidget
		    (lambda (article &optional (class "default"))
		      (format nil "<span class=\"~a\"><div class=\"article\">~
                                     <p>~a</p>~
                                   </div></span>"
			      class
			      (html (get-item 'article article)))))
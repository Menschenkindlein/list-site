(in-package #:list-site)

;; Parser rules

(setf (gethash 'article *default-classificators*)
      (get-year))

(setf (gethash 'main *reading-funcs*) (lambda (stream)
					(read stream)))

;; Printers rules

(add-html-structure 'main
		    (lambda (&rest vidgets)
		      (format nil
			      "~
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
  <head>
    <link type=\"text/css\" href=\"~a\" rel=\"stylesheet\">
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
</html>"                      (html (db-get "default" 'style "main"))
                              (mapcar #'html vidgets))))

(add-html-structure 'author-vidget
		    (lambda (link-text author
			     &optional classificator (class "default"))
		      (format nil "<span class=\"~a\"><div class=\"author\">~
                                     <p>~a</p>~
                                   </div></span>"
			      class
			      (html (list 'inner-author
					  link-text
					  author
					  classificator)))))

(add-html-structure 'article-vidget
		    (lambda (link-text article
			     &optional classificator (class "default"))
		      (format nil "<span class=\"~a\"><div class=\"article\">~
                                     <p>~a</p>~
                                   </div></span>"
			      class
			      (html (list 'inner-article
					  link-text
					  article
					  classificator)))))

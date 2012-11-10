(in-package #:list-site)

;; Parser rules

(default-copy-grammar main)

(site-defrule main (* character)
  (:lambda (result)
    (cons 'main-body (main-parse 'main (text result)))))

(main-defrule main (+ (or article-vidget
			  author-vidget)))

(main-defrule author-vidget (and "author " paragraph)
  (:destructure (a result)
    (declare (ignore a))
    (cons 'author-vidget (cdr result))))

(main-defrule article-vidget (and "article " paragraph)
  (:destructure (a result)
    (declare (ignore a))
    (cons 'article-vidget (cdr result))))

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
    <h1>The LIST SITE</h1>
    <div class=\"vidgets\">
    ~{~a~^~%~}
    </div>
  </body>
</html>"                      (html (get-item 'style "main"))
                              (mapcar #'html vidgets))))

(add-html-structure 'author-vidget
		    (lambda (author)
		      (format nil "<div class=\"author\">~@
                                     <p>~a</p>~@
                                   </div>" (html (get-item 'author author)))))

(add-html-structure 'article-vidget
		    (lambda (article)
		      (format nil "<div class=\"article\">~@
                                     <p>~a</p>~@
                                   </div>" (html (get-item 'article article)))))
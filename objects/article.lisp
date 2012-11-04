(in-package #:list-site)

;; Parser rules

(default-copy-grammar article)

(site-defrule article (* character)
  (:lambda (result)
    (cons 'article-body (article-parse 'article (text result)))))

(article-defrule article (and title authors raw-text))

(article-defrule title paragraph
  (:lambda (result)
    (cons 'title (cdr result))))

(article-defrule authors paragraph
  (:lambda (result)
    (cons 'authors (article-parse 'authors-list (second result)))))

(article-defrule authors-list (+ inner-author))

(article-defrule inner-author (and (and (+ (and character (! #\Space)))
					(? character))
				   (? #\Space))
  (:destructure (author rest)
    (declare (ignore rest))
    (list 'inner-author (text author))))

(article-defrule raw-text (* character)
  (:lambda (result)
    (list 'text (text result))))

(article-defrule text (* paragraph))

(article-defrule paragraph-text (+ (or emphasis
				       inner-article
				       character)))

(article-defrule emphasis (and "em{" (+ (and character (! #\}))) character "}")
  (:destructure (em text lc me)
    (declare (ignore em me))
    (list 'emphasis (text text lc))))

(article-defrule inner-article (and "article{"
				    (+ (and character (! #\})))
				    character "}")
  (:destructure (em text lc me)
    (declare (ignore em me))
    (list 'inner-article (text text lc))))

;; Printers rules

(add-html-structure 'article
		    (lambda (name body)
		      (let ((filename
			     (merge-pathnames
			      (make-pathname
			       :directory
			       '(:relative "result" "articles")
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
				(second (second body))))))

(add-html-structure 'article-body
		    (lambda (title authors text)
		      (format nil
			      "~
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
  <head>
    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />
    <title>~a</title>
  </head>
  <body>
  ~a
  ~a
  ~a
  </body>
</html>"                      (second title)
                              (html title)
			      (html authors)
			      (html text))))

(add-html-structure 'title
		    (lambda (title)
		      (format nil "  <h1>~a</h1>" title)))

(add-html-structure 'authors
		    (lambda (&rest authors)
		      (format nil "  <p class=\"authors\">~{~a~^ ~}</p>"
			      (mapcar #'html authors))))

(add-html-structure 'inner-author
		    (lambda (author)
		      (format nil (html (get-item 'author author)))))

(add-html-structure 'inner-article
		    (lambda (article)
		      (format nil (html (get-item 'article article)))))

(add-html-structure 'text
		    (lambda (text)
		      (format nil "  <div>~%~{      ~a~%~}    </div>"
			      (mapcar #'html
				      (article-parse 'text text)))))

(add-html-structure 'paragraph
		    (lambda (paragraph)
		      (format nil "<p>~{~a~}</p>"
			      (mapcar #'html
				      (article-parse 'paragraph-text
						     paragraph)))))

(add-html-structure 'emphasis
		    (lambda (emphasized)
		      (format nil "<i>~a</i>" emphasized)))

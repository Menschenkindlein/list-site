(in-package #:list-site)

;; Parser rules

(defun get-year ()
  (princ-to-string
   (nth 5 (multiple-value-list
	   (decode-universal-time
	    (get-universal-time))))))

(setf (gethash 'article *default-classificators*)
      (get-year))

(setf (gethash 'article *reading-funcs*)
      (lambda (stream)
	(article-parse
	 'article
	 (read-to-string stream))))

(default-copy-grammar article)

(article-defrule article (and title authors raw-text)
  (:lambda (result)
    (cons 'article result)))

(article-defrule title paragraph
  (:lambda (result)
    (cons 'title (cdr result))))

(article-defrule authors paragraph
  (:lambda (result)
    (cons 'authors (article-parse 'authors-list (second result)))))

(article-defrule authors-list (+ inner-author))

(article-defrule inner-author (and (+ (and (! #\Space) character))
				   (? #\Space))
  (:destructure (author rest)
    (declare (ignore rest))
    (list 'inner-author (text author) (text author))))

(article-defrule raw-text (* character)
  (:lambda (result)
    (list 'text (text result))))

(article-defrule text (* paragraph))

(article-defrule paragraph-text (+ (or emphasis
				       inner-article
				       character)))

(article-defrule emphasis (and "em{" (+ (and (! #\}) character)) "}")
  (:destructure (em text me)
    (declare (ignore em me))
    (list 'emphasis (text text))))

(article-defrule inner-article (and "article{"
				    (+ (and (! #\}) character))
				    character "}")
  (:destructure (em text me)
    (declare (ignore em me))
    (list 'inner-article (text text))))

;; Printers rules

(add-html-structure 'article
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
		    (lambda (link-text author &optional classificator)
		      (format nil "<a href=\"~a\">~a</a>"
			      (html (db-get classificator
					    'author
					    author))
			      link-text)))

(add-html-structure 'inner-article
		    (lambda (link-text article &optional classificator)
		      (format nil "<a href=\"~a\">~a</a>"
			      (html (db-get classificator
					    'article
					    article))
			      link-text)))

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

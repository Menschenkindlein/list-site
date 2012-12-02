(in-package #:list-site)

(defvar *local-root* nil "relative path to root")

(defun make-local-pathname (&key directory name type)
  (let ((*root* *local-root*))
    (make-my-pathname :directory directory :name name :type type)))

(defvar *reading-funcs* (make-hash-table))

(make-grammar default)

(default-defrule whitespace (+ (or #\Space #\Tab))
  (:constant #\Space))

(default-defrule newline (and #\Newline (? whitespace))
  (:constant #\Space))

(default-defrule word (and (+ (and (! whitespace)
				   character))
			   (? whitespace))
  (:destructure (word space)
    (declare (ignore space))
    (text word)))

(default-defrule paragraph (and (+ (and (! (and newline newline))
					(or newline character)))
				(* newline))
  (:destructure (par-text newlines)
    (declare (ignore newlines))
    (list 'paragraph (string-trim '(#\Space) (text par-text)))))

(ucg::make-printer html
		   :terminal (lambda (terminal) (princ-to-string terminal))
		   :default (lambda (&rest unknown)
			      (apply #'concatenate
				     'string
				     (mapcar #'html
					     unknown))))

(add-html-structure 'object
		    (lambda (name classificator body)
		      (let ((filename
			     (make-pathname
			      :directory (unless (eql 'main (first body))
					     `(:relative ,(name-to-string
							   (first body) t)
							 ,classificator))
			      :name name
			      :type (case (first body)
				      (style "css")
				      (otherwise "html")))))
			(let ((*local-root* (unless (eql 'main (first body))
					      (make-pathname
					       :directory '(:relative
							    :up :up))))
			      (filename (merge-pathnames filename
							 (merge-pathnames
							  (make-pathname
							   :directory
							   '(relative "result"))
							  *root*))))
			  (unless (probe-file filename)
			    (ensure-directories-exist filename)
			    (with-open-file
				(file filename
				      :direction :output
				      :if-exists :error
				      :if-does-not-exist :create)
			      (format file (html body)))))
			(when *local-root*
			  (setf filename
				(merge-pathnames
				 filename
				 *local-root*)))
			filename)))

(ucg::make-printer edit
		   :terminal (lambda (terminal) (prin1-to-string terminal))
		   :default (lambda (&rest unknown)
			      (prin1-to-string unknown)))
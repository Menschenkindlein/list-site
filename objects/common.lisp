(in-package #:list-site)

(defvar *year* "2012" "Is not used as for now")

(defvar *root* "/home/maximo/WorkOnNow/list-site/")

(defvar *result-root* (merge-pathnames (make-pathname
					:directory '(:relative "result"))
				       *root*))

(defvar *local-root* nil "relative path to root")

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

(default-copy-grammar site)

(ucg::make-printer html
		   :terminal (lambda (terminal) (princ-to-string terminal))
		   :default (lambda (&rest unknown)
			      (apply #'concatenate
				     'string
				     (mapcar #'html
					     unknown))))

(defun read-file-to-string (filename)
  (with-open-file (file filename)
    (loop for line = (read-line file nil) with result doing
	       (if line
		   (push line result)
		   (return (format nil "~{~a~%~}" (nreverse result)))))))

(defun get-item (item-class name)
  (let ((filename (merge-pathnames
		   (make-pathname
		    :directory
		    `(:relative "source" ,(format nil "~(~a~)s" item-class))
		    :name name
		    :type (format nil "~(~a~)" item-class))
		   *root*)))
    (list item-class name
	  (site-parse item-class (read-file-to-string filename)))))

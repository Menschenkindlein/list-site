(in-package #:list-site)

;; READING

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

;; PRINTING

(def-printer edit
    :terminal (lambda (terminal) (princ-to-string terminal))
    :default (lambda (&rest unknown)
	       (prin1-to-string unknown)))

(edit-defmacro 'object
	       (lambda (name object-type body)
		 (let ((filename
			(merge-pathnames
			 (make-pathname
			  :directory `(:relative "source")
			  :name name
			  :type (name-to-string object-type))
			 *root*)))
		   (unless (probe-file filename)
		     (ensure-directories-exist filename)
		     (with-open-file
			 (file filename
			       :direction :output
			       :if-exists :error
			       :if-does-not-exist :create)
		       (format file
			       (edit
				(or body
				    (progn
				      (print "New object!")
				      (get-default-structure
				       object-type)))))))
		   filename)))

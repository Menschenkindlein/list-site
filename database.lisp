(in-package #:list-site)

(defvar *database* (make-hash-table :test #'equal))

(defun get-databases ()
  (loop for database in (directory
			 (make-my-pathname
			  :directory '(:relative "database"
					         :wild)
			  :name :wild
			  :type "db"))
     collecting
       (cons (cons
	      (pathname-name database)
	      (intern (string-upcase
		       (car (last (pathname-directory database))))
		      (find-package :list-site)))
	     database)))

(defun load-databases ()
  (princ #\Newline)
  (princ "Loading databases...")
  (loop for (database-spec . pathname) in (get-databases)
     with *package* = (find-package :list-site) doing
       (setf (gethash database-spec *database*)
	     (with-open-file (file pathname)
	       (read file))))
  (princ "done"))

(defun save-databases ()
  (cl-fad:delete-directory-and-files
   (make-my-pathname :directory '(:relative "database"))
   :if-does-not-exist :ignore)
  (maphash (lambda (database-spec value)
	     (let ((path (make-my-pathname
			  :directory `(:relative "database"
						 ,(name-to-string
						   (cdr database-spec)))
			  :name (car database-spec)
			  :type "db")))
	       (ensure-directories-exist path)
	       (with-open-file (file
				path
				:direction :output
				:if-does-not-exist :create)
		 (print value file))))
	   *database*))

(defun db-get (classificator object-type name)
  (unless classificator
    (setf classificator (get-default object-type)))
  (list 'object name classificator object-type
	(cdr (assoc name
		    (gethash (cons classificator object-type) *database*)
		    :test #'string=))))

(defun db-save (classificator object-type name body)
  (let ((dest (assoc name
		     (gethash (cons classificator object-type) *database*)
		     :test #'string=)))
    (if dest
	(setf (cdr dest) body)
	(setf (gethash (cons classificator object-type)
				  *database*)
	      (acons name body (gethash (cons classificator object-type)
					*database*))))))
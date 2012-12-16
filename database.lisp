(in-package #:list-site)

(defvar *database* (make-hash-table))

(defun get-databases ()
  (loop for database in (directory
			 (make-my-pathname
			  :directory '(:relative "database")
			  :name :wild
			  :type "db"))
     collecting
       (cons (intern (string-upcase
		      (pathname-name database))
		     (find-package :list-site))
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
			  :directory `(:relative "database")
			  :name (name-to-string database-spec)
			  :type "db")))
	       (ensure-directories-exist path)
	       (with-open-file (file
				path
				:direction :output
				:if-does-not-exist :create)
		 (print value file))))
	   *database*))

(defun db-get (object-type name)
  (list 'object name object-type
	(cdr (assoc name
		    (gethash object-type *database*)
		    :test #'string=))))

(defun db-save (object-type name body)
  (let ((dest (assoc name
		     (gethash object-type *database*)
		     :test #'string=)))
    (if dest
	(setf (cdr dest) body)
	(setf (gethash object-type *database*)
	      (acons name body (gethash object-type
					*database*))))))
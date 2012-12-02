(in-package #:list-site)

(defvar *database* (make-hash-table :test #'equal))

(defun load-databases ()
  (loop for (database-spec . pathname) in (get-databases) doing
       (setf (gethash database-spec *database*) (read-from-file pathname))))

(defun save-databases ()
  (ensure-directories-exist (make-my-pathname
			     :directory '(:relative "database")))
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
				:if-exists :overwrite
				:if-does-not-exist :create)
		 (print value file))))
	   *database*))

(defun db-get (classificator object-type name)
  (unless classificator
    (setf classificator (get-default object-type)))
  (list 'object name classificator
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
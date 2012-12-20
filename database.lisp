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
	(cdr (assoc (intern (string-upcase name) :list-site)
                    (gethash object-type *database*)
                    :key #'car))))

(defun db-save (object-type name body)
  (let ((dest (assoc (intern (string-upcase name) :list-site)
                     (gethash object-type *database*)
                     :key #'car)))
    (if dest
        (setf (cdr dest) body)
        (setf (gethash object-type *database*)
              (acons (cons
                      (intern (string-upcase name) :list-site)
                      (make-helper object-type body))
                     body
                     (gethash object-type *database*))))))

(defun db-select (object-type fn-selector)
  (loop
     for ((name . search-helper) . object) in (gethash object-type
                                                       *database*)
     with result
     doing
       (when (funcall fn-selector search-helper)
         (push
          (list 'object
                (name-to-string name)
                object-type
                object)
          result))
       finally (return result)))

(defmacro db-where (&rest clauses)
  `#'(lambda (object)
       (and
        ,@(loop while clauses
             collecting
               (let ((field (pop clauses))
                     (value (pop clauses)))
                 (case value
                   (:contains
                    `(find ,(pop clauses)
                           (getf object ,field)
                           :test #'equal))
                   (otherwise
                    `(equal (getf object ,field)
                            ,value))))))))
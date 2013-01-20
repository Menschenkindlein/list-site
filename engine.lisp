(in-package #:list-site)

(defun init (&rest args)
  (declare (ignore args))
  (setf *root* *default-pathname-defaults*)
  (load-printers-declarations)
  (load-objects-declarations)
  (load-databases)
  (let ((*package* (find-package :list-site-user)))
    (loop
       (print 'list-site-user::list-site>) (finish-output)
       (print (restart-case (eval (read))
		(return-to-toplevel () "Evaluation aborted"))))))

(defun get-objects-to-consume ()
  (let (result)
    (maphash (lambda (key value)
	       (declare (ignore value))
	       (push
		(loop for object in
		     (directory
		      (make-my-pathname
		       :directory `(:relative "source")
		       :name :wild
		       :type (name-to-string key)))
		   collecting
		     (list key                                    ;; object-type
			   (pathname-name object)                 ;; object-name
			   object))                               ;; path
		result))
	     *objects*)
    (apply #'append result)))

(defun consume ()
  (loop
     for i by 1
     for (object-type name pathname)
     in (get-objects-to-consume)
     with *package* = (find-package :list-site)
     doing
       (with-open-file (file pathname)
	 (db-save object-type name
		  (funcall (get-reading object-type)
			   file)))
     doing
       (delete-file pathname)
     finally (progn (unless (zerop i) (save-databases))
		    (return
		      (format nil "Consumed ~r object~:p" i)))))

(defun excrect (object name)
  (let ((*package* (find-package :list-site)))
    (edit (db-get object name))))

(defun build (printer type name)
  (cl-fad:delete-directory-and-files
   (make-my-pathname :directory '(:relative "result"))
   :if-does-not-exist :ignore)
  (funcall printer (db-get type name)))

(defun exit ()
  (sb-ext:quit))
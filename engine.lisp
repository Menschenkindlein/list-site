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
		       :directory `(:relative "source"
					      ,(name-to-string key t)
					      :wild)
		       :name :wild
		       :type (name-to-string key)))
		   collecting
		     (list key                                    ;; object-type
			   (car (last (pathname-directory object))) ; classificator
			   (pathname-name object)                 ;; object-name
			   object))                               ;; path
		result))
	     *objects*)
    (apply #'append result)))

(defun consume ()
  (loop
     for i by 1
     for (object-type classificator name pathname)
     in (get-objects-to-consume)
     with *package* = (find-package :list-site)
     doing
       (with-open-file (file pathname)
	 (db-save classificator object-type name
		  (funcall (get-reading object-type)
			   file)))
     doing
       (delete-file pathname)
     finally (progn (save-databases)
		    (return
		      (format nil "Consumed ~r object~:p" i)))))

(defun excrect (object name &optional classificator)
  (let ((*package* (find-package :list-site)))
    (edit (db-get (or classificator (get-default object))
		  object
		  name))))

(defun build (printer type name &optional classificator)
  (cl-fad:delete-directory-and-files
   (make-my-pathname :directory '(:relative "result"))
   :if-does-not-exist :ignore)
  (funcall printer (db-get classificator type name)))

(defun exit ()
  (sb-ext:quit))
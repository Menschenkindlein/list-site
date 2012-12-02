(in-package #:list-site)

(defun init (&optional source)
  (unless source
    (load-databases)))

(defun consume ()
  (loop
     for (object-type classificator name pathname)
     in (get-objects-to-consume)
     doing
       (with-open-file (file pathname)
	 (db-save classificator object-type name
		  (funcall (gethash object-type *reading-funcs*)
			   file))))
  (cl-fad:delete-directory-and-files
   (make-my-pathname :directory '(:relative "source"))
   :if-does-not-exist :ignore))

(defun excrect (object name &optional classificator)
  (edit (db-get (or classificator (get-default object))
		object
		name)))
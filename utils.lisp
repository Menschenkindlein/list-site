(in-package #:list-site)

(defvar *default-classificators* (make-hash-table))

(defun get-default (object-type)
  (gethash object-type *default-classificators*))

(defun name-to-string (name &optional plural)
  (format nil "~(~a~)~:[~;s~]" name plural))

(defun read-from-file (filespec)
  (with-open-file (file filespec)
    (read file)))

(defvar *root* (make-pathname :directory
			      (pathname-directory
			       (asdf:system-definition-pathname :list-site))))

(defun make-my-pathname (&key directory name type)
  (merge-pathnames
   (make-pathname :directory directory
		  :name name
		  :type type)
   *root*))

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

(defun get-objects-to-consume ()
  (loop for object in (directory
			 (make-my-pathname
			  :directory '(:relative "source"
				                 :wild
				                 :wild)
			  :name :wild
			  :type :wild))
     collecting
       (list (intern (string-upcase                 ;; object-type
		      (pathname-type object))
		     (find-package :list-site))
	     (car (last (pathname-directory object))) ; classificator
	     (pathname-name object)                 ;; object-name
	     object)))                              ;; path

;; (defmacro make-path (object-type name &key result classificator)
;;   (let ((consuming-path
;; 	 (make-my-pathname :directory '(:relative "source")))
;; 	(result-path
;; 	 (make-my-pathname :directory '(:relative "result"))))
;;     `(let ((classificator (or ,classificator
;; 			      (get-default ,object-type))))
;;        (merge-pathnames
;; 	(make-pathname :directory `(:relative ,classificator
;; 					      ,(name-to-string ,object-type t))
;; 		       :name ,name
;; 		       :type (name-to-string ,object-type))
;; 	,(if result
;; 	     result-path
;; 	     consuming-path)))))

(defun read-to-string (stream)
  (loop for line = (read-line stream nil) with result doing
       (if line
	   (push line result)
	   (return (format nil "~{~a~%~}" (nreverse result))))))

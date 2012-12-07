(in-package #:list-site)

;; *OBJECTS*

(defvar *objects* (make-hash-table))

(defun get-reading (object-type)
  (getf (gethash object-type *objects*)
	:reading-function))

(defun add-reading (object-type reading-function)
  (setf (getf (gethash object-type *objects*)
	      :reading-function)
	reading-function))

(defun get-default (object-type)
  (getf (gethash object-type *objects*)
	:default-classificator))

(defun add-default (object-type default-classificator)
  (setf (getf (gethash object-type *objects*)
	      :default-classificator)
	default-classificator))

;; PATHNAMES

(defvar *root* nil "Directory where the engine work.")

(defun make-my-pathname (&key directory name type)
  (merge-pathnames
   (make-pathname :directory directory
		  :name name
		  :type type)
   *root*))

(defun make-rel-dir (&rest directories)
  (make-pathname :directory (cons :relative directories)))

;; NAME-TO-STRING

(defun name-to-string (name &optional plural)
  (format nil "~(~a~)~:[~;s~]" name plural))

;; READING

(defun read-to-string (stream)
  (loop for line = (read-line stream nil) with result doing
       (if line
	   (push line result)
	   (return (format nil "~{~a~%~}" (nreverse result))))))

(in-package #:list-site)

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

;; UTILS

(defun convert-date (day month year)
  (+ day (* month 32) (* (- year 2012) 512)))
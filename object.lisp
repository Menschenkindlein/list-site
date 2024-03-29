(in-package #:list-site)

;; *OBJECTS*

(defvar *objects* (make-hash-table))

(defun load-objects-declarations ()
  (princ #\Newline)
  (princ "Loading objects declarations...") (finish-output)
  (loop for object in (directory
		       (make-my-pathname
			:directory '(:relative "objects")
			:name :wild
			:type "lisp"))
     with *package* = (find-package :list-site)
     doing (load object))
  (princ "done"))

(defun make-object (name &key (default-classificator "default")
		              (reading-function #'read)
		              (default-structure (list name ""))
                              (helper-maker (lambda (&rest rest)
                                              (declare (ignore rest)))))
  (export name)
  (setf (gethash name *objects*)
	(list :default-structure default-structure
	      :default-classificator default-classificator
	      :reading-function reading-function
              :helper-maker helper-maker)))

(defun get-reading (object-type)
  (getf (gethash object-type *objects*)
	:reading-function))

(defun get-default-structure (object-type)
  (getf (gethash object-type *objects*)
	:default-structure))

(defun make-helper (object-type body)
  (apply (getf (gethash object-type *objects*)
               :helper-maker)
         body))

(defun add-default (object-type default-classificator)
  (setf (getf (gethash object-type *objects*)
	      :default-classificator)
	default-classificator))

;; Example object

(make-object 'verbatim
	     :reading-function (lambda (stream)
				 (list 'verbatim
				       (read-to-string stream))))

(add-edit-structure 'verbatim
		    (lambda (verbatim)
		      verbatim))

;; End of example

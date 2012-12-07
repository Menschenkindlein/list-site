(in-package #:list-site)

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

(defmacro make-object (name &key (default-classificator "default")
		                 (reading-function #'read))
  `(progn
     (export ',name)
     (add-default ',name ,default-classificator)
     (add-reading ',name ,reading-function)))
(in-package #:list-site)

(defun load-printers-declarations ()
  (princ #\Newline)
  (princ "Loading printers declarations...") (finish-output)
  (loop for printer in (directory
			(make-my-pathname
			 :directory '(:relative "printers")
			 :name :wild
			 :type "lisp"))
     with *package* = (find-package :list-site)
     doing (load printer))
  (princ "done"))

(defmacro def-printer (name &key terminal default)
  `(progn
     (export ',name)
     (ucg::make-eval ,name
		     :terminal ,terminal
		     :default ,default)))
(in-package #:list-site)

;; Parser rules

;; (default-copy-grammar style)

(setf (gethash 'style *default-classificators*)
      "default")

(setf (gethash 'style *reading-funcs*) (lambda (stream)
					 (list 'style (read-to-string stream))))

;; Printers rules

(add-html-structure 'style
		    (lambda (style)
		      style))
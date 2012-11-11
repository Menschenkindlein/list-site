(in-package #:list-site)

;; (defun find-all-files-on-the-depth (dir depth)
;;   (let ((directory (cons :relative (make-list depth :initial-element :wild))))
;;     (remove-if (lambda (x) (find x (directory
;; 				    (merge-pathnames
;; 				     (make-pathname :directory directory
;; 						    :name :wild
;; 						    :type nil)
;; 				     dir))
;; 				 :test #'equal))
;; 	       (directory
;; 		(merge-pathnames
;; 		 (make-pathname :directory directory
;; 				:name :wild
;; 				:type :wild)
;; 		 dir)))))

(defun build ()
  (cl-fad:delete-directory-and-files (merge-pathnames "result" *root*)
				     :if-does-not-exist :ignore)
  (let ((*package* (find-package :list-site)))
    (html (get-item 'main "test"))))
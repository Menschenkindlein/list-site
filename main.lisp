(in-package #:list-site)

(defun build ()
  (cl-fad:delete-directory-and-files (merge-pathnames "result" *root*)
				     :if-does-not-exist :ignore)
  (html (get-item 'article "test")))
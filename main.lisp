(in-package #:list-site)

(defun build ()
  (cl-fad:delete-directory-and-files
   (make-my-pathname :directory '(:relative "result"))
   :if-does-not-exist :ignore)
  (setf list-site::*database* (make-hash-table :test #'equal))
  (init)
  (let ((*package* (find-package :list-site)))
    (consume))
  (save-databases)
  (html (db-get "2012" 'main "test")))
;;;; rpg.tail-recursive-defun.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :rpg.tail-recursive-defun
  :serial t
  :depends-on (:fiveam)
  :components ((:file "package")
               (:file "rpg.tail-recursive-defun")
               (:file "test")))


(defmethod perform ((o test-op) (c (eql (find-system :rpg.tail-recursive-defun))))
  (load-system :rpg.tail-recursive-defun)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :rpg.tail-recursive-defun.internal :rpg.tail-recursive-defun))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*

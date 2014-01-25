;;;; rpg.tail-recursive-defun.lisp -*- Mode: Lisp;-*- 

(cl:in-package :rpg.tail-recursive-defun.internal)
;; (in-readtable :rpg.tail-recursive-defun)


;;; "rpg.tail-recursive-defun" goes here. Hacks and glory await!

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun ncons (arg)
    (list arg))


  (defun do-code (x)
    (cond ((null x) nil)
          ((atom x)
           (let ((char1 (char (string x) 0)))
             (cond ((member char1 '(#\? #\*)) x)
                   (t (list 'quote x)))))
          ((and (atom (car x))
                (char= #\* (char (string (car x)) 0)))
           `(append ,(do-code (car x)) ,(do-code (cdr x))))
          (t `(cons ,(do-code (car x)) ,(do-code (cdr x))))))


  (defun α-grab-tails (args def ?go-label)
    (cond ((atom def) nil)
          ((and (atom (car def))
                (eq 'tail-recur (car def)))
           (cond ((equal args (cdr def))		;calling with same args!
                  (rplaca def 'go)
                  (rplacd def (ncons ?go-label)))
                 (t (do ((args args (cdr args))
                         (newargs (cdr def) (cdr newargs))
                         (sets nil
                               `(,.sets
                                 ,.(cond ((eq (car args) (car newargs))
                                          nil)
                                         (t (ncons
                                             (let ((sym (gensym)))
                                               (cons
                                                `(,(car args) ,@sym)
                                                `(setq ,(car args)
                                                       ,(sublis (mapcar #'car sets)
                                                                (car newargs)))))))))))
                        ((null args)
                         ((lambda(l-exp)
                            (rplaca def (car l-exp))
                            (rplacd def (cdr l-exp)))
                          (α-optimize-λ (mapcar #'cdar sets)
                                          (nconc (mapcar #'cdr sets)
                                                 (ncons `(go ,?go-label)))
                                          (mapcar #'caar sets))))))))
          (t (mapc (lambda (def)
                     (α-grab-tails args def ?go-label))
                   def))))


  (defun α-optimize-λ (vars body bindings)
    (do ((vars vars (cdr vars))
         (bindings bindings (cdr bindings))
         (nvars nil (nconc nvars
                           (cond ((any-memq (car vars) body)
                                  (ncons (car vars)))
                                 (t nil))))
         (nbins nil (nconc nbins
                           (cond ((any-memq (car vars) body)
                                  (ncons (car bindings)))
                                 (t nil)))))
        ((null vars)
         `((lambda (,@nvars) ,@body) ,@nbins))))


  (defun any-memq (x y)
    (cond ((null y) nil)
          ((atom y) (eq x y))
          (t (or (any-memq x (car y))
                 (any-memq x (cdr y)))))))


(defmacro ccode (x)
  (do-code x))


(defmacro tail-recursive-defun (?f-name (&rest *args) &body body)
  (let ((*args (copy-tree *args))
        (*definition (copy-tree body))
        (?go-label (gensym)))
    (α-grab-tails *args *definition ?go-label)
    (ccode
     (defun ?f-name (*args) 
       (prog nil
          ?go-label
             (return (progn *definition)))))))


;;; *EOF*

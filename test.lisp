;;;; test.lisp -*- Mode: Lisp;-*- 

(cl:in-package rpg.tail-recursive-defun.internal)
;; (in-readtable :rpg.tail-recursive-defun)

(def-suite rpg.tail-recursive-defun)
(in-suite rpg.tail-recursive-defun)


(defun macroexpand-1= (pat macro-form)
  (equalp pat
          (subst-if 'g1
                    (lambda (x) 
                      (and (symbolp x)
                           (not (symbol-package x))))
                    (macroexpand-1 macro-form))))


(test tail-recursive-defun
  (is-true (macroexpand-1= '(defun fib (n a1 a2)
                             (prog ()
                                g1 (return
                                     (progn
                                       (cond ((zerop n) a2) ((= 1 n) a1)
                                             (t ((lambda (g1)
                                                   (setq n (1- n))
                                                   (setq a1 (+ a1 a2))
                                                   (setq a2 g1)
                                                   (go g1)) a1)))))))
                           '(tail-recursive-defun fib (n a1 a2)
                             (cond ((zerop n) a2)
                                   ((= 1 n) a1)
                                   (t (tail-recur (1- n) (+ a1 a2) a1)))))))


;;; *EOF*


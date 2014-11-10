;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :rpg.tail-recursive-defun
  (:use)
  (:export :tail-recursive-defun
           :tail-recur))


(defpackage :rpg.tail-recursive-defun.internal
  (:use :rpg.tail-recursive-defun :cl :fiveam))


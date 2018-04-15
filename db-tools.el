;;; db-tools --- 

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/db-tools
;; Package-Requires: 
;; Copyright (C) 2016, Noah Peart, all rights reserved.
;; Created:  5 November 2016

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:

;; [![Build Status](https://travis-ci.org/nverno/db-tools.svg?branch=master)](https://travis-ci.org/nverno/db-tools)

;;; Code:
(eval-when-compile
  (require 'cl-lib)
  (require 'nvp-macro)
  (defvar sql-product)
  (defvar sql-buffer)
  (defvar sql-mode-abbrev-table)
  (defvar zeal-at-point-docset))

(nvp-package-dir db-tools--dir)
(nvp-package-load-snippets db-tools--dir)

(declare-function sql-set-product "sql")
(declare-function sql-set-sqli-buffer "sql")
(declare-function sql-product-font-lock "sql")

;; ------------------------------------------------------------

;;; SQLi

;; font-lock everything in sql interactive mode
(defun db-tools-sqli-font-lock ()
  (unless (eq 'oracle sql-product)
    (sql-product-font-lock nil nil)))

;; Suppress indentation in sqli.
(defun db-tools-sqli-suppress-indent ()
  (set (make-local-variable 'indent-line-function)
       (lambda () 'noindent)))

(defvar db-tools--sql-buffer)

;; Switch to the corresponding sqli buffer.
(defun db-tools-sqli-switch ()
  (interactive)
  (if (eq major-mode 'sql-mode)
      (let ((buff (current-buffer)))
        (if sql-buffer
            (progn
              (pop-to-buffer sql-buffer)
              (goto-char (point-max)))
          (sql-set-sqli-buffer)
          (when sql-buffer
            (db-tools-sqli-switch)))
        (if sql-buffer
            (setq db-tools--sql-buffer buff)
          (user-error "No sqli buffer found.")))
    (when db-tools--sql-buffer
      (pop-to-buffer db-tools--sql-buffer))))

;;; Zeal

;; Default the zeal lookup to postgres when product changes.
(defun db-tools-psql-set-zeal ()
  (when (eq sql-product 'postgres)
    (set (make-local-variable 'zeal-at-point-docset) "psql")))

(defadvice sql-set-product (after set-zeal-docset activate)
  (db-tools-psql-set-zeal))

;;; Abbrevs

;; Don't expand in strings or comments.
(defun sql-in-code-context-p ()
  (let ((ppss (syntax-ppss)))
    (and (null (elt ppss 3))    ; inside string
         (null (elt ppss 4))))) ; inside comment

;; FIXME: pre-abbrev-expand-hook -> abbrev-expand-function
;; Only expand abbrevs in code context.
(defun db-tools-sql-pre-abbrev-expand-hook ()
  (setq local-abbrev-table
        (if (sql-in-code-context-p)
            sql-mode-abbrev-table)))

;; ------------------------------------------------------------
;;; Setup local

(defun db-tools-setup-local ()
  (setq-local indent-line-function 'sql-indent-line)
  (make-local-variable 'pre-abbrev-expand-hook)
  (add-hook 'pre-abbrev-expand-hook
            'db-tools-sql-pre-abbrev-expand-hook nil 'local)
  (db-tools-psql-set-zeal))

(defun db-tools-sqli-setup-local ()
  (db-tools-sqli-font-lock)
  (db-tools-sqli-suppress-indent)
  (db-tools-psql-set-zeal))

;; ------------------------------------------------------------
(provide 'db-tools)
;;; db-tools.el ends here

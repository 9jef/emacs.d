;;; init.el --- JEF's emacs.d init file.            -*- lexical-binding: t; -*-
;; Copyright (C) 2018  JEF

;; Author: JEF <fletcherje88@gmail.com>

;;; Commentary:

;; JEF's emacs configuration - made with emacs 26

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; my info
(setq user-full-name "J E F"
      user-mail-address "fletcherje88@gmail.com")

;; raise default filesizes
(setq gc-cons-threshold 50000000)
(setq large-file-warning-threshold 100000000)

;; some startup
(setq-default
 inhibit-startup-message t
 initial-major-mode 'fundamental-mode
 initial-scratch-message (concat ";; Happy hacking, " user-login-name " - Emacs ♥ you!\n\n"))

;; encoding
(prefer-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8-auto-unix)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; local lisp
(let ((path (expand-file-name "~/.emacs.d/lisp")))
  (if (file-accessible-directory-p path)
      (add-to-list 'load-path path t)))

;; package.el
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
             '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)

;; get use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; load use-package
(setq use-package-always-ensure t)
(use-package diminish)

(eval-when-compile
  (defvar use-package-verbose t)
  (require 'use-package))

(use-package moe-theme
	     :config
	     (load-theme 'moe-light t))

;; better defaults
(setq tab-width 4)
(fset 'yes-or-no-p 'y-or-n-p)
(use-package better-defaults
	     :config
	     (require 'better-defaults))

;; modeline
(defmacro diminish-major-mode (mode new-name)
  `(add-hook (intern (concat (symbol-name ,mode) "-hook"))
             '(lambda () (setq mode-name ,new-name))))

(diminish-major-mode 'lisp-interaction-mode "λ»")
(diminish-major-mode 'emacs-lisp-mode "Eλ")
(diminish-major-mode 'lisp-mode "λ")

;; better modeline
(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t
        sml/theme 'respectful)
  (sml/setup))

;; ido
(use-package ido
  :config
  ;; smex is a better replacement for M-x
  (use-package smex
    :bind
    ("M-x" . smex)
    ("M-X" . smex-major-mode-commands))

  ;; Use ido everywhere we can
  (use-package ido-completing-read+
    :config
    (ido-ubiquitous-mode 1))

  ;; This makes ido work vertically
  (use-package ido-vertical-mode
    :config
    (setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right
          ido-vertical-show-count t)
    (ido-vertical-mode 1))

  ;; This adds flex matching to ido
  (use-package flx-ido
    :config
    (flx-ido-mode 1)
    (setq ido-enable-flex-matching t
          flx-ido-threshold 1000))

  ;; Turn on ido everywhere we can
  (ido-mode 1)
  (ido-everywhere 1)

  (setq resize-mini-windows t
        ido-use-virtual-buffers t
        ido-auto-merge-work-directories-length -1))

;; better undo 
(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode:
  :config
  (global-undo-tree-mode 1))

;; syntax highlighting / checking
(use-package company
  :ensure t
  :diminish company-mode
  :config
  (add-hook 'after-init-hook #'global-company-mode))

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook 'global-flycheck-mode)
  (add-hook 'flycheck-mode-hook 'jc/use-eslint-from-node-modules)
  (add-to-list 'flycheck-checkers 'proselint)
  (setq-default flycheck-highlighting-mode 'lines)
  ;; Define fringe indicator / warning levels
  (define-fringe-bitmap 'flycheck-fringe-bitmap-ball
    (vector #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00011100
            #b00111110
            #b00111110
            #b00111110
            #b00011100
            #b00000000
            #b00000000
            #b00000000
            #b00000000
            #b00000000))
  (flycheck-define-error-level 'error
    :severity 2
    :overlay-category 'flycheck-error-overlay
    :fringe-bitmap 'flycheck-fringe-bitmap-ball
    :fringe-face 'flycheck-fringe-error)
  (flycheck-define-error-level 'warning
    :severity 1
    :overlay-category 'flycheck-warning-overlay
    :fringe-bitmap 'flycheck-fringe-bitmap-ball
    :fringe-face 'flycheck-fringe-warning)
  (flycheck-define-error-level 'info
    :severity 0
    :overlay-category 'flycheck-info-overlay
    :fringe-bitmap 'flycheck-fringe-bitmap-ball
    :fringe-face 'flycheck-fringe-info))

(flycheck-define-checker proselint
    "A linter for prose."
    :command ("proselint" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message (one-or-more not-newline)
                       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
              line-end))
    :modes (text-mode markdown-mode gfm-mode org-mode))

(use-package magit
  :bind (("C-M-g" . magit-status)))

;; project navigation 
(use-package projectile
  :diminish projectile-mode
  :delight '(:eval (concat " " (projectile-project-name))
                   :config (projectile-global-mode)))

;; useful to find commands
(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5
        which-key-popup-type 'side-window
        which-key-side-window-location 'right))

;; version control 
(use-package diff-hl
  :config
  ;; We only need diff-hl-margin-mode if we're in a terminal.
  (global-diff-hl-mode 1)
  (unless (window-system)
    (diff-hl-margin-mode 1)))

;; Revert buffers if they've changed on disk
(global-auto-revert-mode 1)
(setq auto-revert-verbose nil)

;;; Programming stuff
(which-function-mode 1)
(add-hook 'prog-mode-hook
          (lambda ()
            (linum-mode 1)
            (setq show-trailing-whitespace t)))

;; Todo/FIX tagging etc.
(use-package fic-mode
  :diminish fic-mode
  :config
  (add-hook 'prog-mode-hook 'fic-mode))

;; common lisp
(global-set-key (kbd "C-c e l") #'find-library)

(setq slime-lisp-implementations '((sbcl ("sbcl")))
      slime-default-lisp 'sbcl
      slime-contribs '(slime-fancy slime-quicklisp slime-asdf))

(let ((path "/usr/local/share/doc/HyperSpec/"))
  (if (file-accessible-directory-p path)
      (setq common-lisp-hyperspec-root (concat "file://" path))))

(use-package paredit
  :hook (eval-expression-minibuffer-setup . paredit-mode))

(use-package paren-face
  :defer)

(defun my-emacs-lisp-mode-hook-fn ()
  (set (make-local-variable 'lisp-indent-function) #'lisp-indent-function)
  (paredit-mode 1)
  (local-set-key (kbd "C-c S") (global-key-binding (kbd "M-s")))
  (local-set-key (kbd "C-c C-z")
                 (lambda () (interactive) (switch-to-buffer "*scratch*")))
  (show-paren-mode 1)
  (paren-face-mode))


(use-package slime-company
  :defer)

(use-package slime
  :demand
  :config
  (slime-setup '(slime-fancy slime-company slime-quicklisp slime-asdf slime-cl-indent)))

(defun my-lisp-mode-hook-fn ()
  (set (make-local-variable 'lisp-indent-function)
       #'common-lisp-indent-function)
  (paredit-mode 1)
  (local-set-key (kbd "C-c S") (global-key-binding (kbd "M-s")))
  (show-paren-mode 1)
  (paren-face-mode)
  (set (make-local-variable 'company-backends) '(company-slime))
  (company-mode)
  (local-set-key "\C-i" #'company-indent-or-complete-common))

(add-hook 'emacs-lisp-mode-hook #'my-emacs-lisp-mode-hook-fn)
(add-hook 'lisp-mode-hook #'my-lisp-mode-hook-fn)

;; -*- lexical-binding: nil -*-

;; I wanted to play around with Lisps so I had to bite the bullet and install Emacs.
;; This started out as a minimal evil mode setup to match what I use in IdeaVim and
;; Neovim, but overtime it grew to include the best minibuffer and help packages,
;; because this editor is an amazing beast and those packages make it a lot more
;; fun to use.

;;;
;;; Initialize the packaging stuff (To update 'M-x list-packages'-> type 'Ux')
;;;

;; Moar Moar Moar
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (setq my/first-run t)
  (package-install 'use-package))

;; Global settings
(defmacro comment (&rest body) "Comment out one or more s-expressions." nil)
(setq find-function-C-source-directory "/FS/Projects/emacs-31.1")
(when (file-exists-p custom-file) (load custom-file))
(defalias 'gsk #'global-set-key)
(defalias 'lsk #'local-set-key)
(defalias 'dk  #'define-key)


;; I use this everywhere and give it 5 ⭐s because it does everything
;; well and CONFINES each package's tweaks to a single s-expression
;; which makes it a lot easier to debug my endless Emacs hacks 🙃
(require 'use-package)
(setq use-package-always-ensure t)      ; well duh...
(setq use-package-compute-statistics t)

;; It got too big so I organized it into multiple files
(add-to-list 'load-path "~/.config/emacs/settings/")

(load-library "my-evil.el")           ; must be first!
(load-library "my-theme.el")
(load-library "my-convenience.el")
(load-library "my-minibuffer.el")
(load-library "my-lang.el")
(load-library "my-lisps.el")
(load-library "my-fun.el")
(load-library "my-tts.el")


;; Done loading, start the server for emacsclient calls
(server-start)

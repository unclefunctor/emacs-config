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
(setq package-user-dir (file-truename "~/.local/share/emacs/repos/")
      package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
;; (byte-recompile-directory package-user-dir nil 'force) ; eval to recompile the packages


;; Global settings
(defmacro comment (&rest body) "Comment out one or more s-expressions." nil)
(setq find-function-C-source-directory "/FS/Projects/emacs-31.1")
(when (file-exists-p custom-file) (load custom-file))
(defvar my/config-dir (expand-file-name "~/.config/emacs/settings/"))
(setq inhibit-startup-echo-area-message "psd")
(defalias 'gsk #'global-set-key)
(defalias 'lsk #'local-set-key)
(defalias 'dk  #'define-key)


;; Auto compile setting files ignoring sym link mismatches
;; This was an utter PITA to get working, but evil mode
;; uses a lot of hooks, so hopefully Emacs will be snappier 🤔
(defun my/auto-config-compile ()
  "Automatically byte compiles my settings files"
  (let ((true-name       (file-truename buffer-file-name))
        (true-config-dir (file-truename my/config-dir)))
    (when (and (string-prefix-p true-config-dir true-name)
               (string-match-p "\\.el$" true-name))
      (byte-compile-file true-name))))
(add-hook 'after-save-hook #'my/auto-config-compile)


(require 'use-package)
(setq use-package-always-ensure t)      ; well duh...
(setq use-package-compute-statistics t)


;;
;; It got too big so I organized it into multiple files
;;
(add-to-list 'load-path my/config-dir)
(load-library "my-evil")                ; must be first!

(dolist (hack '("my-terms-and-shells"   ; appending '.el' stops the auto native compile!
                "my-convenience"
                "my-minibuffer"
                "my-theme"
                "my-music"
                "my-lisps"
                "my-lang"
                "my-org"
                "my-tts"
                "my-fun"))
  (load-library hack))


;; Done loading, start the server for emacsclient calls
(server-start)

;;*********
;;*WARNING*  Don't forget to M-X byte-recompile-file this guy!
;;*********

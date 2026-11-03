;; -*- lexical-binding: nil -*-

;;;
;;; Syntax highlighting, LSPs, snippets, etc…
;;;

(require 'evil)                                     ; needed for native compilation

;; I don't like LSP nagging, but they are helpful when dealing with mega OOP frameworks
(use-package eglot
  :ensure nil                                       ; built in for 29+
  :hook ((java-ts-mode       . eglot-ensure)
         (python-ts-mode     . eglot-ensure)        ; they do a good integrating the docs
         (eglot-managed-mode . flymake-mode))       ; dynamic linting was a TERRIBLE idea

  :init
  (let ((jdtls (file-truename "~/.local/share/emacs/jdtls/bin")))
    (add-to-list 'exec-path jdtls)
    (setenv "PATH" (concat jdtls path-separator (getenv "PATH"))))
  :config
  (evil-define-key '(normal visual) eglot-mode-map (kbd "C-q") #'eldoc))


;; Does not auto switch to the file's tree-sitter mode after
;; an compile/install, so you will need to do a M-x revert-buffer :(
(use-package treesit-auto
  :init
  (setq treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode))
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))) ; why did I need this patch?

(use-package treesit-fold                   ; treesit has the best fold support
  :defer t)

(dolist (hook '(c-ts-mode-hook              ; treesit has a different mode name for each language
                c++-ts-mode-hook
                java-ts-mode-hook
                python-ts-mode-hook))
  (add-hook hook (lambda ()
    (require 'treesit-fold)                 ; lazy load when it is actually needed
    (treesit-fold-mode 1)

    (setq-local indent-tabs-mode nil)
    (setq-local tab-width 3)

    ;; Construct "major-mode"-indent-offset variable name and then set it to 3
    (let ((ts-off (intern (concat (symbol-name major-mode) "-indent-offset"))))
      (when (boundp ts-off) (set (make-local-variable ts-off) 3))))))


(use-package font-lock                      ; JetBrains spoiled me
  :ensure nil
  :init
  (custom-set-faces
   '(font-lock-comment-face ((t (:slant italic))))
   '(font-lock-doc-face ((t (:slant italic))))
   '(font-lock-comment-delimiter-face ((t (:slant italic))))))


(use-package markdown-mode                  ; markdown-ts-mode is better, but I want to use its preview
  :commands markdown-preview)

(use-package markdown-ts-mode
  :ensure nil                               ; built in for 31+
  :mode ("\\.md\\'" . markdown-ts-mode)
  :hook (markdown-ts-mode . (lambda ()
    (setq-local markdown-command `("pandoc" "--standalone" ,(concat "--metadata=title:" (buffer-name))))
    (evil-define-key '(normal visual) 'markdown-ts-mode-map (kbd "M-P") #'markdown-preview))))


(use-package yasnippet                      ; I really need to force myself to use this LoL
  :defer t
  :config
  (run-with-idle-timer 2 nil (lambda ()          ; delay the scan of ⬇⬇⬇'s massive directory
    (yas-global-mode 1))))

(use-package yasnippet-snippets
  :defer t
  :after yasnippet)


(use-package rainbow-delimiters             ; nice when debugging, otherwise distracting as hell
  :after evil
  :bind ("M-p" . rainbow-delimiters-mode)
  :init
  (evil-define-key '(normal visual) 'global (kbd "<M-p>") #'rainbow-delimiters-mode))


(use-package toml-mode
  :mode "\\.toml\\'")


(use-package yaml-mode
  :mode "\\.yml\\'")


;; Tabs
(setq-default tab-width 3)                  ; I'm an odd ball
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 3)             ; in case tree-sitter is not working
(setq-default sh-basic-offset 3)
(setq-default standard-indent 3)

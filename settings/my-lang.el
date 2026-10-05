;; -*- lexical-binding: nil -*-

;;;
;;; Syntax highlighting, LSPs, snippets, etc…
;;;

(require 'evil)                                     ; needed for native compilation

;; I don't like LSP's but they are helpful when dealing with mega OOP frameworks
(use-package eglot
  :ensure nil                                       ; built in for 29+
  :hook ((java-ts-mode        . eglot-ensure)
          (eglot-managed-mode . flymake-mode-off))  ; dynamic linting was a TERRIBLE idea

  :init
  (let ((jdtls (file-truename "~/.local/share/emacs/jdtls/bin")))
    (add-to-list 'exec-path jdtls)
    (setenv "PATH" (concat jdtls path-separator (getenv "PATH")))))


;; Does not auto switch to the file's tree-sitter mode after
;; an compile/install, so you will need to do a M-x revert-buffer :(
(use-package treesit-auto
  :init
  (setq treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode)))


(use-package markdown-mode                  ; markdown-ts-mode is better, but I want to use its preview
  :commands markdown-preview)

(use-package markdown-ts-mode
  :ensure nil                               ; built in for 31+
  :mode ("\\.md\\'" . markdown-ts-mode)
  :hook (markdown-ts-mode . (lambda ()
    (setq-local markdown-command `("pandoc" "--standalone" ,(concat "--metadata=title:" (buffer-name))))
    (evil-define-key '(normal visual) 'markdown-ts-mode-map (kbd "M-P") #'markdown-preview))))


(use-package yasnippet
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


;; Tabs
(setq-default tab-width 3)                  ; I'm an odd ball
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 3)             ; in case tree-sitter is not working
(setq-default sh-basic-offset 3)
(setq-default standard-indent 3)

(dolist (hook '(c-ts-mode-hook
                c++-ts-mode-hook
                java-ts-mode-hook
                python-ts-mode-hook))
  (add-hook hook (lambda ()                      ; override tree-sitter's overrides!
    (setq-local indent-tabs-mode nil)
    (setq-local tab-width 3)
    ;; construct "major-mode"-indent-offset vairable name and then set it to 3
    (let ((ts-off (intern (concat (symbol-name major-mode) "-indent-offset"))))
      (when (boundp ts-off) (set (make-local-variable ts-off) 3))))))

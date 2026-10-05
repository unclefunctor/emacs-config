;; -*- lexical-binding: nil -*-

(require 'evil)                             ; needed to fix the compiled version

(use-package racket-mode
  :mode ("\\.rkt\\'" . racket-mode)
  :hook (
  (racket-mode . racket-xp-mode)
  (racket-repl-mode . (lambda ()
    "My Racket REPL fixes"
    (evil-define-key 'insert racket-repl-mode-map (kbd "<up>") #'racket-repl-previous-input)
    (evil-define-key 'insert racket-repl-mode-map (kbd "<down>") #'racket-repl-next-input)
    (lsk (kbd "M-n") nil)
    (lsk (kbd "M-p") nil))))

  :custom
  (racket-browse-url-function #'eww-browse-url)

  :config
  ;; Automatically insert opening bracket
  (add-hook 'racket-mode-hook #'racket-smart-open-bracket-mode))


(use-package geiser
  :defer t
  :hook
  (geiser-repl-mode . (lambda ()
    "My Geiser REPL fixes"
    (evil-define-key 'insert geiser-repl-mode-map (kbd "<return>") #'geiser-repl-maybe-send)
    (lsk (kbd "C-S-r") 'comint-history-isearch-backward-regexp)
    (lsk (kbd "M-r") nil)))

  :config
  (setq geiser-active-implementations '(chez))
  (evil-define-key '(normal visual) geiser-mode-map (kbd "C-q") #'geiser-doc-symbol-at-point)
  (evil-define-key '(normal visual) geiser-mode-map (kbd "C-j") #'(lambda ()
    "My Geiser eval and print"
    (interactive)
    (let* ((ip (point))
           (_  (geiser-eval-last-sexp '(4)))
           (lp (point)))
      (goto-char ip)
      (insert "; ⇒ ")
      (goto-char (+ lp 4)))))

  (setq geiser-chez-binary "/usr/bin/chez-scheme")
  (use-package geiser-chez
    :after geiser))


;; Least painful parens package, I tried the paredit flavors
;; and what little benefit I got was overridden by rigid
;; formatting and random s-expression corruptions.  This guy
;; is old, but simple enough to fork and tweak:
(use-package evil-lisp-state
  :vc (:url "https://github.com/unclefunctor/evil-lisp-state" :rev :newest)
  :after evil
  :commands evil-lisp-state ; autoload for ⬇⬇⬇ hooks
  :hook ((lisp-interaction-mode . my/lisp-mode)
         (emacs-lisp-mode       . my/lisp-mode)
         (fennel-mode           . my/lisp-mode)
         (racket-mode           . my/lisp-mode)
         (scheme-mode           . my/lisp-mode)
         (lisp-mode             . my/lisp-mode))
  :config
  ;; I had to add '(evil-lisp-state-global t) to custom.el
  ;; to make it to work on the non-elisp files
  (evil-lisp-state-leader ","))

(defun my/lisp-mode ()
  "Set my standard Lisp defaults"
  (setq-local lisp-indent-offset 2)
  (setq-local tab-width 2)
  (setq-local standard-indent 2)
  (prettify-symbols-mode 1)
  (evil-lisp-state))

(use-package smartparens            ; ^^^'s dependency, TODO needs configuring
  :config
  (require 'smartparens-config)
  (smartparens-strict-mode))

;; -*- lexical-binding: nil -*-

;;;
;;; Misc UI conveniences
;;;

(require 'evil)                             ; needed to fix the compiled version

(setq-default calc-algebraic-mode t)
(setq history-length 40
      ispell-program-name "hunspell"
      confirm-kill-emacs #'yes-or-no-p
      browse-url-browser-function #'browse-url-xdg-open)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode)
(save-place-mode)


(use-package recentf                      ; recent files (used in a lot of other packages)
  :ensure nil                             ; built in

  :custom
  (recentf-max-saved-items 40)

  :config
  (recentf-mode)
  (add-to-list 'recentf-exclude "emacs\-31")
  (add-to-list 'recentf-exclude "/usr/share/")
  (add-to-list 'recentf-exclude "/emacs/elpa/")
  (add-to-list 'recentf-exclude "emacs/custom\.el")
  (add-hook 'emacs-startup-hook (lambda ()
    ;; (message "")                          ; start clean, yes I have OCD, what's your point?
    (message "%d packages in %s" (length package-activated-list) (emacs-init-time))
    (when (and recentf-list (null (cdr command-line-args)))
      (run-with-idle-timer 0.1 nil (lambda ()      ; this hook fires too soon, so wait. Which
        (find-file (car recentf-list))))))))  ; implies that the init time ⬇⬇⬇ is BS, LoL


(use-package dired                        ; make it comfy
  :ensure nil                             ; built in

  :commands (dired dired-jump)
  :hook (dired-mode . dired-hide-details-mode)
  :bind (:map dired-mode-map
          ("C-x C-m" . dired-toggle-read-only))

  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-recursive-copies 'top)
  (dired-recursive-deletes 'top)
  (delete-by-moving-to-trash t)
  (dired-create-destination-dirs 'ask)

  :config
  (evil-define-key 'normal dired-mode-map (kbd "<return>") 'my/dired-RET)       ; poor man's treemacs
  (evil-define-key 'normal dired-mode-map (kbd "S-<return>") 'dired-find-file)

  (use-package all-the-icons-dired
    :hook (dired-mode . all-the-icons-dired-mode)
    :config
    (setq all-the-icons-dired-monochrome nil))

  (use-package dired-subtree
    :bind (:map dired-mode-map
                ("<tab>" . dired-subtree-toggle)
                ("<backtab>" . dired-subtree-cycle))
    :config
    (setq dired-subtree-use-backgrounds nil)))

(defun my/dired-RET ()
  "Open files in the other window"
  (interactive)
  (let ((filename (dired-get-filename nil t)))
    (if (and filename (file-directory-p filename))
      (dired-find-file)
      (dired-find-file-other-window))))


(use-package casual                       ; Emacs has too many commands to remember
  :defer t

  :init
  (setq casual-keybinding-primary "M-c"
    casual-keybinding-secondary "M-C"
    ediff-window-setup-function 'ediff-setup-windows-plain)
  (run-with-idle-timer 1.5 nil (lambda ()      ; I can't just :bind M-h to a λ that loads it and repeats M-h,
    (casual-init))))                      ; because this beast takes too long to set its tmenu hooks


(use-package helpful                      ; totally worth the extra bloat
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)
   ("<f1> f" . helpful-callable)
   ("<f1> v" . helpful-variable)
   ("<f1> k" . helpful-key)
   ("<f1> x" . helpful-command)))


(use-package embark             ; menus for selections
  :bind
  (("C-;" . embark-dwim)        ;; good alternative: M-.
   ;; ("C-." . embark-act)      ;; pick some comfortable binding (conflicts with evil-mode)
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)

  ;; My stuff:
  (evil-define-key '(normal visual) 'global (kbd "<leader>.") #'embark-act)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))


(use-package embark-consult
  :after embark)    ; only need to install it, embark loads it after consult if found


;; TODO figure out how to use, maybe have eshell send command result to a grep buffer?
(use-package wgrep  ; modify and save grep buffer results (alternative to sed)
  :bind (;; Bind the activation command inside the grep-mode buffer
         :map grep-mode-map
         ("C-x C-q" . wgrep-change-to-wgrep-mode)
         ("e" . wgrep-change-to-wgrep-mode))
  :custom
  ;; Automatically save underlying file buffers after you press C-c C-e
  (wgrep-auto-save-buffer t)
  ;; Keep the grep buffer read-only after applying modifications
  ;; (wgrep-change-readonly-file t)
)


(use-package transpose-frame              ; rotate the frames
  :bind (:map evil-motion-state-map ("C-w t" . transpose-frame)))


(use-package sudo-edit                    ; never leave Emacs!
  :commands sudo-edit)


(use-package which-key                    ; Emacs has too many key combos to remember
  :ensure nil                             ; built in
  :config
  (which-key-mode)
  (setq which-key-popup-type 'side-window
        which-key-side-window-location 'bottom))


(use-package winner                       ; save and load window positions, ...
  :ensure nil                             ; built in
  :init
  (winner-mode 1))


(use-package popper                       ; treat aux windows as pop-ups
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  (setq popper-display-control nil)       ; t -> popups open on the bottom
  (setq popper-display-function #'display-buffer-in-child-frame)
  :config
  (popper-mode +1)
  (popper-echo-mode +1))                  ; For echo area hints


(use-package magit
  :defer t
  :commands magit-project-status)


;; I can't lazy load this guy because :bind-keymap does not work with
;; evil's <leader>.  If I catch the 1st command, load the package, and
;; install the prefix map, I would have to write some gnarly hacks to
;; inject the prefix and the command.  Way too much work to save 40 ms!
(use-package project
  :ensure nil                             ; built in
  :init                                   ;
  (evil-define-key* '(normal visual) 'global (kbd "<leader>g") project-prefix-map)
  (dk project-prefix-map (kbd "v") #'magit-project-status))


(use-package corfu                        ; works well enough that I don't need LSPs
  :hook
  (prog-mode . (lambda () (setq-local corfu-auto t)))
  :init
  (global-corfu-mode))


(use-package rg
  :commands (rg rgrep)
  :config
  (rg-enable-default-bindings))


(use-package hydra    ; create commands that are sequenced by spamming sub keys
  :defer t)

;;;
;;; My hydras
;;;

(require 'windmove)   ; Emacs default window adjustment keys are a PITA to spam
(defhydra hydra-border (global-map "C-M-w")
  "frame resizer"
  ("h"       my/move-border-left)
  ("j"       my/move-border-down)
  ("k"       my/move-border-up)
  ("l"       my/move-border-right)
  ("<left>"  my/move-border-left)
  ("<up>"    my/move-border-down)
  ("<down>"  my/move-border-up)
  ("<right>" my/move-border-right)
  ("q" nil))

(defun my/move-border-left (arg)
  "Move window border left."
  (interactive "p")
  (if (windmove-find-other-window 'right)
      (shrink-window-horizontally arg)
    (enlarge-window-horizontally arg)))

(defun my/move-border-right (arg)
  "Move window border right."
  (interactive "p")
  (if (windmove-find-other-window 'right)
      (enlarge-window-horizontally arg)
    (shrink-window-horizontally arg)))

(defun my/move-border-up (arg)
  "Move window border up."
  (interactive "p")
  (if (windmove-find-other-window 'up)
      (enlarge-window arg)
    (shrink-window arg)))

(defun my/move-border-down (arg)
  "Move window border down."
  (interactive "p")
  (if (windmove-find-other-window 'up)
      (shrink-window arg)
    (enlarge-window arg)))

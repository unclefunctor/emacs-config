;; -*- lexical-binding: nil -*-

;;;
;;; Misc UI conveniences
;;;

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
  (add-to-list 'recentf-exclude "emacs/custom\.el")
  (add-hook 'emacs-startup-hook (lambda ()
    (when (and recentf-list (null (cdr command-line-args)))
      (run-with-idle-timer 1.1 nil (lambda ()  ; this hook fires too soon, so wait. Which
        (find-file (car recentf-list))))) ; implies that the init time ⬇⬇⬇ is BS, LoL
    (message "%d packages in %s" (length package-activated-list) (emacs-init-time)))))


(use-package dired                        ; make it comfy
  :ensure nil                             ; built in

  :commands (dired dired-jump)
  :hook (dired-mode . dired-hide-details-mode)
  :bind (:map dired-mode-map ("C-x C-m" . dired-toggle-read-only))

  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-recursive-copies 'top)
  (dired-recursive-deletes 'top)
  (delete-by-moving-to-trash t)
  (dired-create-destination-dirs 'ask)

  :config
  (use-package all-the-icons-dired
    :hook (dired-mode . all-the-icons-dired-mode)
    :config
    (setq all-the-icons-dired-monochrome nil)))


(use-package eshell                       ; PITA to customize, but it's the best shell PERIOD
  :ensure nil                             ; built in
  :commands eshell

  :init
  (gsk (kbd "M-t") 'eshell)

  :hook
  (eshell-mode . (lambda ()
    (lsk (kbd "M-r")   nil)
    (lsk (kbd "C-S-r") #'consult-history)
    (edk 'insert eshell-mode-map (kbd "<up>")     #'eshell-previous-matching-input-from-input)
    (edk 'insert eshell-mode-map (kbd "<down>")   #'eshell-next-matching-input-from-input)
    (edk 'insert eshell-mode-map (kbd "M-h")      #'eshell-backward-argument)
    (edk 'insert eshell-mode-map (kbd "M-l")      #'eshell-forward-argument)
    (edk 'insert eshell-mode-map (kbd "<return>") #'eshell-send-input)
    (edk 'insert eshell-mode-map (kbd "C-d") #'(lambda () ; Linux > Windows PERIOD
      "Make C-d inside an empty line exit"
      (interactive)
      (if (eobp)
        (eshell-life-is-too-much)
        (delete-char 1))))))

  :config
  (setq eshell-banner-message "")
  (evil-set-initial-state 'eshell-mode 'insert)

  ;; Add visual/ncurses programs here:
  (setq eshell-visual-commands '("htop" "less" "nvim"))

  (with-eval-after-load 'em-hist          ; cancel the eshell-hist override
    (dk eshell-hist-mode-map (kbd "M-r") nil))

  (setq eshell-prompt-function #'(lambda ()
    (concat
      (propertize "╭" 'face '(:foreground "firebrick2"))
      (propertize "[" 'face '(:foreground "firebrick2" :weight bold))
      (abbreviate-file-name (eshell/pwd))
      (propertize "]" 'face '(:foreground "firebrick2" :weight bold))
      "\n"
      (propertize "λ" 'face '(:foreground "MediumPurple2" :weight bold))   ; use purpur to show that it is an e(macs)shell
      " ")))                                                               ; and not vterm
  (setq eshell-prompt-regexp "^λ ")

  ;; Ripped from https://github.com/agzam/mxp (shell script to pipe in and out of Emacs)
  ;; The function 'b' can be used to pipe a buffer into an eshell command.  E.g.:
  ;; b #<> | rg DEBUG
  ;; or you can press C-c M-b to select a buffer rather than typing #<buffer name>
  (defun eshell/b (buf-or-regexp)
    "Output buffer content of buffer matching BUF-OR-REGEXP."
    (let ((buf (if (bufferp buf-or-regexp)
                 buf-or-regexp
                 (cl-loop for b in (buffer-list)
                   thereis (and (string-match-p buf-or-regexp (buffer-name b)) b)))))
      (when buf
        (with-current-buffer buf (buffer-substring-no-properties (point-min) (point-max)))))))


(use-package eshell-vterm                 ; vterm > term-mode  One more reason to switch to Linux 😀
  :commands eshell-vterm-mode
  :hook (eshell-mode . eshell-vterm-mode)

  :config
  (eshell-vterm-mode)
  (add-hook 'vterm-exit-functions (lambda (buf event)
    (when (string-match-p "finished" event) (kill-buffer buf)))))


(use-package vterm                        ; by far the best terminal for Vim
  :commands vterm

  :init
  (gsk (kbd "M-T") 'vterm)

  :config
  (dk vterm-mode-map (kbd "M-e") (key-binding (kbd "M-e"))) ; cancel the vterm override
  (dk vterm-mode-map (kbd "M-r") (key-binding (kbd "M-r"))) ; ""

  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"
        vterm-shell "env NOFETCH=1 bash"
        vterm-kill-buffer-on-exit t
        vterm-max-scrollback 10000))


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
  (edk '(normal visual) 'global (kbd "<leader>.") #'embark-act)

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


(use-package origami                      ; text folding
  :hook (yaml-mode . origami-mode))


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


(use-package project
  :ensure nil                             ; built in
  :init
  (edk* '(normal visual) 'global (kbd "<leader>g") project-prefix-map)
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

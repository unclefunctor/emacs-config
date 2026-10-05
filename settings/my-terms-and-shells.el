;; -*- lexical-binding: nil -*-

;;;
;;; I gave this its own file because I will be constantly adding new functions to eshell
;;;

(require 'evil)                             ; needed to fix the compiled version

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


(use-package eshell-vterm                 ; vterm > term-mode  One more reason to switch to Linux 😀
  :commands eshell-vterm-mode
  :hook (eshell-mode . eshell-vterm-mode)

  :config
  (eshell-vterm-mode)
  (add-hook 'vterm-exit-functions (lambda (buf event)
    (when (string-match-p "finished" event) (kill-buffer buf)))))


;; TODO
;; 1 - Mod the visual term launcher to use the full command string, rather than the name
(use-package eshell                       ; the best shell PERIOD
  :ensure nil                             ; built in
  :commands eshell

  :init
  (gsk (kbd "M-t") 'eshell)

  :hook
  (eshell-mode . (lambda ()
    (lsk (kbd "M-r")   nil)
    (lsk (kbd "C-S-r") #'consult-history)
    (evil-define-key 'insert eshell-mode-map (kbd "<up>")     #'eshell-previous-matching-input-from-input)
    (evil-define-key 'insert eshell-mode-map (kbd "<down>")   #'eshell-next-matching-input-from-input)
    (evil-define-key 'insert eshell-mode-map (kbd "M-h")      #'eshell-backward-argument)
    (evil-define-key 'insert eshell-mode-map (kbd "M-l")      #'eshell-forward-argument)
    (evil-define-key 'insert eshell-mode-map (kbd "<return>") #'eshell-send-input)
    (evil-define-key 'insert eshell-mode-map (kbd "C-d") #'(lambda () ; Linux > Windows PERIOD
      "Make C-d inside an empty line exit"
      (interactive)
      (if (eobp)
        (eshell-life-is-too-much)
        (delete-char 1))))))

  :config
  (setq eshell-banner-message "")
  (evil-set-initial-state 'eshell-mode 'insert)

  ;; Add visual/ncurses programs here:
  (setq eshell-visual-commands '("htop" "less" "ssh"))

  (with-eval-after-load 'em-hist          ; cancel the eshell-hist override
    (dk eshell-hist-mode-map (kbd "M-r") nil))

  (setq eshell-prompt-function #'(lambda ()
    (concat
      (propertize "╭" 'face '(:foreground "firebrick2"))
      (propertize "[" 'face '(:foreground "firebrick2" :weight bold))
      (abbreviate-file-name (eshell/pwd))
      (propertize "]" 'face '(:foreground "firebrick2" :weight bold))
      "\n"
      (propertize "λ" 'face '(:foreground "MediumPurple2" :weight bold)) ; purpur shows that it is an e(macs)shell
      " ")))                                                             ; and not vterm (gold)
  (setq eshell-prompt-regexp "^λ ")

  ;; Ripped from https://github.com/agzam/mxp (shell script to pipe in and out of Emacs)
  ;; The function 'b' can be used to pipe a buffer into an eshell command.  E.g.:
  ;; b #<big-ass-file.c> | rg DEBUG
  ;; or you can press C-c M-b to select a buffer rather than typing #<buffer name>
  ;; TODO: this is a good start, but IMHO if there is a selection, use that instead of the whole buffer
  (defun eshell/b (buf-or-regexp)
    "Output buffer content of buffer matching BUF-OR-REGEXP."
    (let ((buf (if (bufferp buf-or-regexp)
                 buf-or-regexp
                 (cl-loop for b in (buffer-list)
                   thereis (and (string-match-p buf-or-regexp (buffer-name b)) b)))))
      (when buf
        (with-current-buffer buf (buffer-substring-no-properties (point-min) (point-max)))))))

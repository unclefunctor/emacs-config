;; -*- lexical-binding: nil -*-

;;;
;;; Vim for the win.  Load FIRST because the rest of my libraries use it!
;;;

(use-package evil
  :init
  (defalias 'edk  #'evil-define-key)      ; defers if the keymap is not loaded (adds a hook)
  (defalias 'edk* #'evil-define-key*)     ; will NOT defer until keymap is loaded which prevents a double hook in :init sections
  (setq evil-want-integration t           ; using evil-collection
        evil-want-keybinding nil          ; evil-collection does the keybindings
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil            ; I prefer using C-S-o
        evil-move-beyond-eol t
        evil-search-module #'evil-search
        evil-ex-complete-emacs-commands nil
        evil-vsplit-window-right t        ; like vim's 'splitright'
        evil-split-window-below t         ; like vim's 'splitbelow'
        evil-shift-round t
        evil-want-Y-yank-to-eol t         ; make Vim's motion language consistent
        evil-undo-system #'undo-redo)     ; 'undo-tree' is harder to use

  :hook (prog-mode .
    (lambda () (modify-syntax-entry ?_ "w")))  ; use Vim's definition of a word

  :config
  (evil-mode)
  (evil-set-leader '(normal visual) (kbd "SPC"))

  (use-package evil-collection            ; Vim-like keybindings everywhere
    :custom
    (evil-collection-binding-overrides
     '((find-usages :state normal :key "gu")))

    :config
    (defalias 'ecdk #'evil-collection-define-key)
    (evil-collection-init))

  (use-package evil-lion
    :config
    (evil-lion-mode))

  (use-package evil-commentary
    :bind (:map evil-normal-state-map
                ("gc" . evil-commentary)))

  (use-package evil-exchange
    :config
    (evil-exchange-cx-install))       ; use Vim's 'cx'instead of 'gx'

  (use-package evil-replace-with-register
    :init
    (evil-replace-with-register-install)
    :config
    (evil-define-key '(normal visual) 'global
      (kbd "gr") #'evil-replace-with-register))

  (use-package evil-visualstar        ; * operator in visual mode
    :config
    (global-evil-visualstar-mode))

  (use-package evil-expat             ; Vim's ex commands
    :defer 1)

  (use-package evil-surround
    :config
    (global-evil-surround-mode))

  (use-package evil-goggles           ; visual hints while editing
    :config
    (custom-set-faces
      '(evil-goggles-default-face
         ((t (:foreground "red"
               :weight bold)))))
    (evil-goggles-use-diff-faces)
    (evil-goggles-mode)

    :custom
    (evil-goggles-duration 0.3))

  (use-package evil-easymotion
    :config
    (edk '(normal visual) 'global (kbd "<leader>j") #'evilem-motion-find-char)
    (edk '(normal visual) 'global (kbd "<leader>k") #'evilem-motion-find-char-backward))

  (use-package evil-xkbswitch         ; switch to English when returning to normal mode
    :vc (:url "https://github.com/linktohack/evil-xkbswitch" :rev :newest)
    :diminish evil-xkbswitch-mode
    :config (evil-xkbswitch-mode 1))

  ;; Relative line numbers are essential in Vim mode
  (setq display-line-numbers-type 'relative)
  (setq display-line-numbers-width 3)
  (global-display-line-numbers-mode)
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  vterm-mode-hook
                  shell-mode-hook
                  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

  ;; Jetbrains has spoiled me
  ;; TODO add times argument and move to global functions, keep pointer is same column too
  (dk evil-normal-state-map (kbd "M-j") (lambda ()
                                          (interactive)
                                          (forward-line 1)
                                          (transpose-lines 1)
                                          (forward-line -1)
                                          (indent-according-to-mode)))
  (dk evil-normal-state-map (kbd "M-k") (lambda ()
                                          (interactive)
                                          (transpose-lines 1)
                                          (forward-line -2)
                                          (indent-according-to-mode)))

  ;; I like consistency, and Bram got some things wrong because he
  ;; copied Vi's Y.  If C and D work to the end of the line, V
  ;; should too.  yy and dd work with the whole line, so vv should
  ;; too. Note: I fixed Y behavior with an evil setting ⬆⬆⬆
  (dk evil-normal-state-map (kbd "v") (lambda ()
    "Adds 'vv' as a motion"
    (interactive)
    (let ((evt (read-event)))
      (if (eq evt ?v)
        (evil-visual-line)
        (setq unread-command-events (cons evt unread-command-events))
        (evil-visual-char)))))
  (dk evil-normal-state-map (kbd "V") (lambda ()
    "Makes 'V' select to end of line"
    (interactive)
    (evil-visual-char)
    (evil-end-of-line)
    (backward-char 1)))              ; match Vim and stop before the EOL

  ;; Fix insert mode's C-v:
  (dk evil-insert-state-map (kbd "C-v") (lambda ()
    "Add a unicode menu inside insert mode's C-v: 'C-v u'"
    (interactive)
    (let ((evt (read-event)))
      (if (eq evt ?u)
        (call-interactively #'insert-char)                            ; unicode selector
        (setq unread-command-events (cons evt unread-command-events)) ; restore the key
        (quoted-insert 1)))))                                         ; mimic evil's C-v

  ;; M-e = toggle last buffer (Vim's C-^)
  (gsk (kbd "M-e") #'(lambda ()          ; default binding used if evil-mode is off
    (interactive)
    (switch-to-buffer nil)))        ; bypass the consult package by passing a nil
  (dk evil-normal-state-map (kbd "M-e") #'evil-buffer)

  ;; Keep your fingers on the home row
  (dk evil-insert-state-map  (kbd "C-è") #'evil-normal-state)         ; C-[ in Italian keyboard layout
  (dk evil-insert-state-map  (kbd "C-d") #'evil-delete-char)
  (dk evil-insert-state-map  (kbd "C-h") #'evil-backward-char)
  (dk evil-insert-state-map  (kbd "C-j") #'evil-next-line)
  (dk evil-insert-state-map  (kbd "C-k") #'evil-previous-line)
  (dk evil-insert-state-map  (kbd "C-l") #'evil-forward-char)
  (dk evil-ex-completion-map (kbd "C-d") #'delete-char)
  (dk evil-ex-completion-map (kbd "C-h") #'left-char)
  (dk evil-ex-completion-map (kbd "C-l") #'right-char)

  ;; Misc tweaks
  (dk evil-motion-state-map (kbd "j") #'evil-next-visual-line)
  (dk evil-motion-state-map (kbd "k") #'evil-previous-visual-line)
  (dk evil-motion-state-map (kbd "M-*") #'evil-ex-nohighlight)
  (dk evil-normal-state-map (kbd "C-,") #'duplicate-line)
  (dk evil-visual-state-map (kbd "C-,") #'duplicate-dwim)
  (dk evil-insert-state-map (kbd "C-a") #'evil-insert-line)
  (dk evil-insert-state-map (kbd "C-e") #'evil-append-line)
  (edk '(normal visual) 'global (kbd "<leader><return>") #'make-frame)
  (edk '(normal visual) 'global (kbd "<leader><S-return>") #'delete-frame)
  (edk '(normal visual) 'global (kbd "<leader>ww") #'toggle-truncate-lines)
  (edk '(normal visual) 'global (kbd "<leader>ws") #'whitespace-mode)
  (edk '(normal visual) 'global (kbd "<leader>rb") #'kill-current-buffer)
  (edk '(normal insert visual) 'global (kbd "C-S-v") #'yank)
  (gsk (kbd "C-V")      #'yank)                 ; C-y is fine, but C-S-v is burned into my neurons :(
  (gsk (kbd "<escape>") #'keyboard-escape-quit) ; works, but maybe 'keyboard-quit is a better fit?
  (gsk (kbd "C-M-u")    #'universal-argument)   ; C-u is overidden by evil-scroll-up
  (gsk (kbd "M-a")      #'mark-whole-buffer)
  (gsk (kbd "M-o")      #'next-buffer)
  (gsk (kbd "M-O")      #'previous-buffer)
  (evil-ex-define-cmd "v" 'evil-view)           ; open as read-only

  ;; Fix the tab key because the default sucks
  (dk evil-insert-state-map (kbd "<tab>") (lambda ()
    "My custom evil-insert-tab function"
    (interactive)
    (cond
      ((derived-mode-p 'vterm-mode)             ; vterm has is own tab function
        (vterm-send-tab))
      ((derived-mode-p 'eshell-mode)            ; the following clause fails in eshell, so force it
        (completion-at-point))
      ((and (boundp 'completion-in-region-mode) ; let Corfu do its thing
         completion-in-region-mode)
        (completion-at-point))
      ((<= (current-column)                     ; indent when in the indention region
         (save-excursion
           (back-to-indentation)
           (current-column)))
        (indent-for-tab-command))
      (t
        (insert-tab)))))                        ; otherwise just insert the tab

  ;; A minimal version of my vim-delete-ws plugin; '.' works, but visual block
  ;; does not. TODO write your own package :)
  (evil-define-motion evil-forward-space (count)
    :type exclusive
    (skip-chars-forward " \t" (line-end-position)))
  (dk evil-motion-state-map (kbd "SPC") #'evil-forward-space)

  ;; Evil's default :w/q commands are annoying
  (evil-ex-define-cmd "q!" #'kill-emacs)
  (evil-ex-define-cmd "wq[a]" (lambda ()
    (interactive)
    (save-some-buffers t t)
    (kill-emacs)))
  (evil-ex-define-cmd "q[uit]" (lambda ()
    (interactive)
    (save-some-buffers nil t)
    (if (run-hook-with-args-until-failure 'kill-emacs-query-functions)
      (kill-emacs)
      (message "Quit aborted."))))
)

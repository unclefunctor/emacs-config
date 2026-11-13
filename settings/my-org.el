;; -*- lexical-binding: nil -*-

(require 'evil)            ; needed for native compilation


(use-package org
  :pin  gnu                ; use the latest instead of the built in one
  :mode ("\\.org\\'" . org-mode)
  :hook (org-mode . (lambda ()
    "Make Org Mode purty"
    (setq-local org-list-indent-offset 4
                line-spacing 0.05)

    (electric-indent-local-mode 1)
    (visual-wrap-prefix-mode)
    (variable-pitch-mode)
    (visual-line-mode)

    ;; Change the attributes of interest, leaving the defaults intact
    (set-face-attribute 'org-level-1          nil :height 1.40 :weight 'bold)
    (set-face-attribute 'org-level-2          nil :height 1.25 :weight 'bold)
    (set-face-attribute 'org-level-3          nil :height 1.15 :weight 'semibold)
    (set-face-attribute 'org-level-4          nil :height 1.08 :weight 'semibold)
    (set-face-attribute 'org-level-5          nil :height 1.04 :weight 'semibold)
    (set-face-attribute 'org-block            nil :height 0.80 :background "#01111E")
    (set-face-attribute 'org-meta-line        nil :background "#01111E")
    (set-face-attribute 'org-block-end-line   nil :background "#01111E")
    (set-face-attribute 'org-block-begin-line nil :background "#01111E")

    ;; Undefault these sections back to be fixed pitch:
    (dolist (face '(org-block
                    org-code
                    org-table
                    org-verbatim
                    org-special-keyword
                    org-meta-line
                    org-checkbox))
      (set-face-attribute face nil :inherit 'fixed-pitch))

    ;; Shrink blank lines to use as item separators, but conflicts with org-indent-mode 😞
    (font-lock-add-keywords nil '(("^[ \t]*\n" 0 '(:height 60) t)) 'append)))

  :custom
  (org-log-done 'note)
  (org-ellipsis " ▾")
  (org-hide-emphasis-markers t)

  :config
  (setq org-confirm-babel-evaluate nil)
  (org-babel-do-load-languages 'org-babel-load-languages '((shell . t)
                                                           (python . t)
                                                           (scheme . t)))

  (use-package org-preview-html           ; HTML preview window
    :commands org-preview-html-mode))


(use-package org-superstar
  :defer t
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●"))
  (org-superstar-item-bullet-alist '((?* . ?•) (?+ . ?◦) (?- . ?╸)))
  (org-hide-leading-stars t))


(use-package evil-org
  :after org-superstar
  :hook (org-mode . (lambda () (evil-org-mode))))


(use-package org-tempo     ; [[info:org#Structure Templates][org#Structure Templates]]
  :ensure nil              ; built into org
  :after org-superstar)    ; I can't use the org package because something preloads it!


(use-package visual-fill-column
  :hook (org-mode . (lambda ()
    (setq visual-fill-column-width 100
          visual-fill-column-center-text t)
    (visual-fill-column-mode 1))))


;; Fix a rare emacs bug that happens when it is launched with
;; an --eval elisp command, and that command was aborted...
(add-hook 'kill-emacs-hook (lambda () (require 'org-clock nil t)))

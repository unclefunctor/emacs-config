;; -*- lexical-binding: nil -*-

(require 'evil)                             ; needed for native compilation

(use-package org
  :pin  gnu                       ; use the latest elpa package instead of the built in one
  :mode ("\\.org\\'" . org-mode)
  :hook (org-mode . (lambda ()
    "Make Org Mode purty"
    (variable-pitch-mode)
    (visual-line-mode)
    (org-indent-mode)

    (set-face-attribute 'org-level-1 nil :height 1.40 :weight 'bold)
    (set-face-attribute 'org-level-2 nil :height 1.25 :weight 'bold)
    (set-face-attribute 'org-level-3 nil :height 1.15 :weight 'semibold)
    (set-face-attribute 'org-level-4 nil :height 1.08 :weight 'semibold)
    (set-face-attribute 'org-level-5 nil :height 1.04 :weight 'semibold)

    ;; Undefault these sections back to be fixed pitch:
    (dolist (face '(org-block
                    org-code
                    org-table
                    org-verbatim
                    org-special-keyword
                    org-meta-line
                    org-checkbox))
      (set-face-attribute face nil :inherit 'fixed-pitch))))

  :custom
  (org-log-done 'note)
  (org-ellipsis " ⌄")
  (org-hide-emphasis-markers t)

  :config
  (evil-define-key '(normal visual) 'global (kbd "gx") #'org-open-at-point-global))


(use-package org-ibullets
  :vc (:url "https://github.com/jamescherti/org-ibullets.el" :rev :newest)
  :hook (org-mode . org-ibullets-mode)

  :custom
  (org-ibullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-tempo     ; [[info:org#Structure Templates][org#Structure Templates]]
  :ensure nil              ; built into org
  :after org-ibullets)     ; I can't use the org package because something preloads it!

(use-package visual-fill-column
  :hook (org-mode . (lambda ()
    (setq visual-fill-column-width 100
          visual-fill-column-center-text t)
    (visual-fill-column-mode 1))))
;

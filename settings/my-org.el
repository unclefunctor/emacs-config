;; -*- lexical-binding: nil -*-

(use-package org
  :pin gnu                                ; use the latest elpa package instead of the built in one

  :mode ("\\.org\\'" . org-mode)

  :config
  (setq org-log-done 'note)
  (edk '(normal visual) 'global (kbd "gx") #'org-open-at-point-global)

  (use-package org-tempo                  ; [[info:org#Structure Templates][org#Structure Templates]]
    :ensure nil                           ; built into org
    :after org)
)

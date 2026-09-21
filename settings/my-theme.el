;; -*- lexical-binding: nil -*-

;;;
;;; Make it purty
;;;


(use-package doom-themes)
(load-theme 'doom-city-lights t)
(custom-set-faces '(default ((t (:background "#011627")))))


(use-package doom-modeline
  :init
  (doom-modeline-mode 1)

  :config
  (set-face-attribute 'mode-line nil
    :family "Inconsolata Nerd Font Mono"
    :height 160)
  (set-face-attribute 'mode-line-inactive nil
    :family "Inconsolata Nerd Font Mono"
    :height 160)

  :custom
  (doom-modeline-height 27))


(use-package all-the-icons
  :init
  (when (boundp 'my/first-run) (all-the-icons-install-fonts)))


(setq
  frame-resize-pixelwise t        ; stop randomly resizing! I should not have to
  frame-inhibit-implied-resize t  ; patch this in 2026 WTFO!
  scroll-margin 1
  scroll-conservatively 0
  scroll-up-aggressively 0.01
  scroll-down-aggressively 0.01
  initial-scratch-message ""
  inhibit-startup-screen t)

(doom-themes-visual-bell-config)
(global-hl-line-mode +1)
(column-number-mode 1)
(window-divider-mode)
(set-fringe-mode 10)
(show-paren-mode 1)
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
(tooltip-mode 0)


;; Fonts
(set-face-attribute 'default nil
                    ;; :font "Monofoki 14"
                    :font "Inconsolata Nerd Font Mono 16"
                    :weight 'regular)
(set-face-attribute 'variable-pitch nil
                    :font "Source Sans Pro 16"
                    :weight 'regular)
(set-face-attribute 'fixed-pitch nil
                    ;; :font "Monofoki 14"
                    :font "Inconsolata Nerd Font Mono 16"
                    :weight 'regular)


;; BG alpha tweaking
(gsk (kbd "s-E") (lambda ()
  (interactive)
  (let* ((old-opa (or (frame-parameter nil 'alpha-background) 100))
         (new-opa (max 0 (- old-opa 3))))
    (set-frame-parameter nil 'alpha-background new-opa))))

(gsk (kbd "s-C-e") (lambda ()
  (interactive)
  (let* ((old-opa (or (frame-parameter nil 'alpha-background) 100))
         (new-opa (min 100 (+ old-opa 3))))
    (set-frame-parameter nil 'alpha-background new-opa))))

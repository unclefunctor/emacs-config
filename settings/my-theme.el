;; -*- lexical-binding: nil -*-

;;;
;;; Make it purty
;;;

(require 'evil)                             ; needed for native compilation

(use-package doom-themes
  :init
  (load-theme 'doom-city-lights t)
  (custom-set-faces '(default ((t (:background "#011627"))))))


(use-package doom-modeline
  :custom
  (doom-modeline-height 29)

  :init
  (doom-modeline-mode 1)

  :config
  (set-face-attribute 'mode-line nil
                      :family "InconsolataLGCNerdFontPropo"
                      :weight 'regular
                      :height 140)
  (set-face-attribute 'mode-line-inactive nil
                      :weight 'regular
                      :family "InconsolataLGCNerdFontPropo"
                      :weight 'regular
                      :height 140))


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
                    ;; :font "Monofoki"
                    ;; :font "Iosevka Nerd Font Mono"
                    ;; :font "InconsolataLGCNerdFont Mono"
                    :font "InconsolataLGCNerdFont"
                    :weight 'regular
                    :height 140)
(set-face-attribute 'variable-pitch nil
                    :font "Source Sans Pro"
                    :weight 'regular
                    :height 160)


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

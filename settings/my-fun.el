;; -*- lexical-binding: nil -*-

;;;
;;; Misc fun stuff
;;;

(require 'evil)                             ; needed for native compilation

(use-package speed-type
  :commands (speed-type-text speed-type-buffer speed-type-region)
  :init
  (evil-set-initial-state 'speed-type-mode 'emacs))


;; Zork, and other Z-machines
(use-package malyon
  :vc (:url "https://github.com/speedenator/malyon" :rev :newest)
  :commands malyon)

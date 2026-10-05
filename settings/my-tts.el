;; -*- lexical-binding: nil -*-

;;;
;;; Finally a Linux TTS that does not sound like ass
;;; Assumes the "kokoro" bash script is in the path
;;;

(require 'evil)                             ; needed for native compilation

(defvar my/kokoro-used nil)                 ; don't stop the container if you never used it

(defun my/kokoro ()
  "Send the current selection to the TTS.  Use an empty selection to stop playback"
  (interactive)
  (setq my/kokoro-used t)
  (if (use-region-p)
    (let* ((selection (buffer-substring-no-properties (region-beginning) (region-end)))
           (command   (concat "kokoro " (shell-quote-argument selection))))
      (start-process-shell-command "kokoro" nil command))
    (start-process-shell-command "kokoro" nil "kokoro"))) ; no selection -> use to preload the container or stop playback

(defun my/stop-kokoro ()
  "Stop the TTS container"
  (when my/kokoro-used (call-process "kokoro" nil nil nil "-s")))
(add-hook 'kill-emacs-hook #'my/stop-kokoro)

(with-eval-after-load 'evil
  (evil-define-key '(normal visual) 'global (kbd "<leader>s") #'my/kokoro)) ; edk is TBD

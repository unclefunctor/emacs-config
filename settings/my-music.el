;; -*- lexical-binding: nil -*-

;;;
;;; I got tired of Strawberry corrupting my playlists.  I just want
;;; to play my audio collection and this guy does exactly that:)  Yes,
;;; it requires Emacs, but I always have Emacs open because even when
;;; I am not programming, I type notes into Org mode files.
;;;
;;; Expects 'mpv' to be installed and 'emms-source-file-default-directory to be
;;; setq'd in "custom.el" to your music library path (the path must end with a '/')
;;;

(defvar my/playlist nil)
(defun my/select-playlist ()
  (let ((path (read-file-name "Playlist file: "
                (concat emms-source-file-default-directory "Playlists/")
                nil t)))
    (setq my/playlist (file-name-sans-extension (file-name-nondirectory path)))
    (emms-stop)
    (emms-playlist-current-clear)
    path))

(defvar my/id nil)
(defun my/emms-notify ()
  (when-let* ((track (emms-playlist-current-selected-track)))
    (message (emms-track-description track))
    (setq my/id (notifications-notify
                  :title       my/playlist
                  :body        (emms-track-description track)
                  :replaces-id my/id))))

(use-package emms
  :commands (emms-pause emms-play-playlist emms-stop emms-browser)
  :hook (
  (emms-player-started . my/emms-notify)
  (emms-player-paused  . (lambda () (unless emms-player-paused-p (my/emms-notify)))))

  :init
  (gsk (kbd "s-SPC") #'(lambda ()
    "Pause/Resume current playlist, otherwise select and start a new one"
    (interactive)
    (if (fboundp 'emms-playlist-current-selected-track)
      (emms-pause)
      (emms-play-playlist (my/select-playlist)))))

  (gsk (kbd "s-S-SPC") #'(lambda ()
    "Select and start a playlist"
    (interactive)
    (emms-play-playlist (my/select-playlist))))

  (gsk (kbd "s-S-s") #'(lambda ()
    "Select, shuffle and start a playlist"
    (interactive)
    (let ((path (my/select-playlist)))
      (emms-add-playlist path)
      (emms-shuffle)
      (emms-start))))

  (gsk (kbd "s-C-SPC") #'(lambda ()
    "Open the Emms browser"
    (interactive)
    (setq my/playlist "Music Library")
    (emms-browser)))

  (add-to-list 'recentf-exclude "emms/history")

  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (require 'notifications)
  (require 'emms-info-tinytag)
  (add-to-list 'emms-info-functions #'emms-info-tinytag)

  (emms-mpris-enable)
  (emms-all)

  (setq emms-player-list             '(emms-player-mpv)
        emms-volume-change-function #'emms-volume-mpv-change)

  (gsk (kbd "<XF86AudioStop>") #'emms-stop)
  (gsk (kbd "<XF86AudioPlay>") #'emms-pause)
  (gsk (kbd "s-n")             #'emms-next)
  (gsk (kbd "<XF86AudioNext>") #'emms-next)
  (gsk (kbd "s-S-n")           #'emms-previous)
  (gsk (kbd "<XF86AudioPrev>") #'emms-previous)
  (gsk (kbd "s-s")             #'emms-shuffle)
  (gsk (kbd "s-C-v")           #'emms-volume-raise)  ; in my DE, s-v raises the master PC volume
  (gsk (kbd "s-C-S-v")         #'emms-volume-lower)) ;    ""     s-S-v lowers the master PC volume

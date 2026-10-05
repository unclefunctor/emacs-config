;; -*- lexical-binding: nil -*-

;;;
;;; I got tired of Strawberry corrupting my playlists.  I just want
;;; to play my audio collection and this guy does exactly that:)  Yes,
;;; it requires Emacs, but I always have Emacs open because even when
;;; I am not programming, I type notes into Org mode files.
;;;
;;; Uses 'mpv' for audio playback, so it must be installed.
;;;

(require 'evil)                             ; needed to fix the compiled version

(defvar my/id nil)
(defun my/emms-notify ()
  "Shows a track info notification"
  (when-let* ((track (emms-playlist-current-selected-track)))
    (message (emms-track-description track))
    (setq my/id (notifications-notify
                  :title       my/playlist
                  :body        (emms-track-description track)
                  :replaces-id my/id))))

(defun my/emms-pause ()
  "Shows a track info notification when playback is paused"
  (unless emms-player-paused-p (my/emms-notify)))

(defvar my/playlist nil)
(defun my/select-playlist ()
  (require 'emms) ; I need this because :bind sometimes fires before everything is loaded
  (let ((path (read-file-name "Playlist file: "
                (concat emms-source-file-default-directory "Playlists/")
                nil t)))
    (setq my/playlist (file-name-sans-extension (file-name-nondirectory path)))
    (emms-stop)
    (emms-playlist-current-clear)
    path))

(defun my/play-pause ()
  "Play/Pause if a track is loaded, otherwise select and start a playlist"
  (interactive)
  (if (fboundp 'emms-playlist-current-selected-track)
    (emms-pause)
    (emms-play-playlist (my/select-playlist))))

(defun my/start-playlist ()
  "Select and start a playlist"
  (interactive)
  (emms-play-playlist (my/select-playlist)))

(defun my/start-shuffled-playlist ()
  "Select and start a shuffled playlist"
  (interactive)
  (let ((playlist (my/select-playlist)))
    (emms-add-playlist playlist)
    (emms-shuffle)
    (emms-start)))

(defun my/browse-music-library ()
  "Open the Emms browser"
  (interactive)
  (setq my/playlist "Music Library")
  (emms-browser))

(use-package emms
  :bind (("s-SPC"   . my/play-pause)
         ("s-S-SPC" . my/start-playlist)
         ("s-C-SPC" . my/browse-music-library)
         ("s-S"     . my/start-shuffled-playlist))  ; WTF "s-S-s" does not work!
  :hook ((emms-player-started . my/emms-notify)
         (emms-player-paused  . my/emms-pause))

  :init
  (setq emms-source-file-default-directory (expand-file-name "~/Music/")) ; :custom fails to set this for "some" binds, again WTFO!
  (add-to-list 'recentf-exclude "emacs/emms/")

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
  (gsk (kbd "s-N")             #'emms-previous)      ; "s-S-n" does not work either
  (gsk (kbd "<XF86AudioPrev>") #'emms-previous)
  (gsk (kbd "s-s")             #'emms-shuffle)
  (gsk (kbd "s-C-v")           #'emms-volume-raise)  ; in my DE, s-v raises the master PC volume
  (gsk (kbd "s-C-S-v")         #'emms-volume-lower)) ;    ""     s-V lowers the master PC volume

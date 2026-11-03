;; -*- lexical-binding: nil -*-

;;;
;;; I got tired of Strawberry corrupting my playlists.  I just want
;;; to play my audio collection and this guy does exactly that:)  Yes,
;;; it requires Emacs, but I always have Emacs open because even when
;;; I am not programming, I type notes into Org mode files.
;;;
;;; Uses 'mpv' for audio playback, so it must be installed.
;;;

(require 'evil)                             ; needed for native compilation

(defvar my/id nil)
(defun my/emms-notify ()
  "Shows a track info notification"
  (when-let* ((track (emms-playlist-current-selected-track)))
    (message (emms-track-description track))
    (setq my/id (notifications-notify
                  :title       (emms-track-description track)
                  :body        my/playlist
                  :replaces-id my/id))))

(defun my/emms-pause ()
  "Shows a track info notification when playback is paused"
  (unless emms-player-paused-p (my/emms-notify)))

(defvar my/playlist nil)

(defun my/volume-raise ()
  "Raise emms' volume"
  (interactive)
  (require 'emms)           ; I may call this before the first playlist loads
  (emms-volume-raise))

(defun my/volume-lower ()
  "Lower emms' volume"
  (interactive)
  (require 'emms)           ; I may call this before the first playlist loads
  (emms-volume-lower))

(defun my/select-playlist ()
  (require 'emms)
  (let ((path (read-file-name "Playlist file: "
                (concat emms-source-file-default-directory "Playlists/")
                nil t)))
    (setq my/playlist (file-name-sans-extension (file-name-nondirectory path)))
    (emms-stop)
    (emms-playlist-current-clear)
    path))

(defun my/play-after-load ()
  (remove-hook 'emms-info-init-done-hook #'my/play-after-load)
  (setq emms-track-description-function #'my/emms-track-description)
  (emms-start))

(defun my/shuffle-and-play-after-load ()
  (remove-hook 'emms-info-init-done-hook #'my/shuffle-and-play-after-load)
  (setq emms-track-description-function #'my/emms-track-description)
  (emms-shuffle)
  (emms-start))

(defun my/play-pause ()
  "Play/Pause if a track is loaded, otherwise select and start a playlist"
  (interactive)
  (if (fboundp 'emms-playlist-current-selected-track)
    (emms-pause)
    (let ((playlist (my/select-playlist)))
      (add-hook 'emms-info-init-done-hook #'my/play-after-load)
      (emms-add-playlist playlist))))

(defun my/start-playlist ()
  "Select and start a playlist"
  (interactive)
  (let ((playlist (my/select-playlist)))
    (add-hook 'emms-info-init-done-hook #'my/play-after-load)
    (emms-add-playlist playlist)))

(defun my/start-shuffled-playlist ()
  "Select and start a shuffled playlist"
  (interactive)
  (let ((playlist (my/select-playlist)))
    (add-hook 'emms-info-init-done-hook #'my/shuffle-and-play-after-load)
    (emms-add-playlist playlist)))

(defun my/previous-replay ()
  "Jump to previous track if the pos < 5 secs, otherwise replay it"
  (interactive)
  (emms-player-mpv-cmd '(get_property time-pos) (lambda (pos err)
    (if (or err (< pos 5.0))
      (emms-previous)
      (emms-player-seek-to 0)
      (my/emms-notify)))))

(defun my/browse-music-library ()
  "Open the Emms browser"
  (interactive)
  (require 'emms)
  (setq my/playlist "Music Library")
  (emms-browser))

(defun my/play-music-library ()
  "Make a shuffled playlist from your library and start playing when done";
  (interactive)
  (require 'emms)
  (emms-stop)
  (emms-playlist-current-clear)
  (setq my/playlist "Music Library")
  (add-hook 'emms-info-init-done-hook #'my/shuffle-and-play-after-load)
  (emms-add-directory-tree emms-source-file-default-directory))

(defun my/emms-track-description (track)
  "Fixes the '<unknown>' artist bug"
  (let ((artist (emms-track-get track 'info-artist))
        (title (emms-track-get track 'info-title))
        (name (emms-track-name track)))
    (cond
      ((and artist title (string= artist "<unknown>")) title)
      ((and artist title) (format "%s - %s" artist title))
      (title title)
      (t (file-name-nondirectory name)))))

(use-package emms
  :bind (("s-SPC"     . my/play-pause)
         ("s-S-SPC"   . my/start-playlist)
         ("s-C-SPC"   . my/play-music-library)
         ("s-C-S-SPC" . my/browse-music-library)
         ("s-R"       . my/start-shuffled-playlist))  ; WTF "s-S-r" does not work!
  :hook ((emms-player-started . my/emms-notify)
         (emms-player-paused  . my/emms-pause))

  :init
  (setq emms-source-file-default-directory (expand-file-name "~/Music/"))
  (add-to-list 'recentf-exclude "emacs/emms/")

  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (require 'notifications)
  (require 'emms-info-tinytag)

  (add-to-list 'emms-info-functions #'emms-info-tinytag)
  (emms-mpris-enable)
  (emms-all)

  (setq emms-volume-change-function  #'emms-volume-mpv-change
        emms-player-list             '(emms-player-mpv)
        emms-repeat-playlist         t
        emms-volume-change-amount    3)

  (gsk (kbd "<XF86AudioStop>") #'emms-stop)
  (gsk (kbd "<XF86AudioPlay>") #'emms-pause)
  (gsk (kbd "s-n")             #'emms-next)
  (gsk (kbd "<XF86AudioNext>") #'emms-next)
  (gsk (kbd "s-N")             #'my/previous-replay) ; "s-S-n" does not work either
  (gsk (kbd "<XF86AudioPrev>") #'my/previous-replay)
  (gsk (kbd "s-r")             #'emms-shuffle)
  (gsk (kbd "s-C-v")           #'my/volume-raise)  ; in my DE, s-v raises the master PC volume
  (gsk (kbd "s-C-S-v")         #'my/volume-lower)) ;    ""     s-V lowers the master PC volume

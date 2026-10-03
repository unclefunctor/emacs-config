;; -*- lexical-binding: nil -*-

;; Optimization ripped from: https://www.jamescherti.com/compiling-emacs/
;;
;; Display the architecture using:
;;   gcc -march=native -Q --help=target | grep march
;;
;; The above command asks the compiler to resolve native for your current CPU
;; and display the resulting target. For example, if the output shows
;; -march=skylake, you know that skylake is the identifier you should pass to
;; -mtune and -march.
;;
;; NOTE: Be sure to clean the ~/.cache/emacs/eln-cache/ to force a recompile
;; with the correct ⬆⬆⬆ CPU architecture
(setq my-cpu-architecture "alderlake")

(setq native-comp-compiler-options `("-O2"
                                     ,(format "-mtune=%s" my-cpu-architecture)
                                     ,(format "-march=%s" my-cpu-architecture)
                                     "-g0"
                                     "-fno-omit-frame-pointer"
                                     "-fno-finite-math-only"))

(setq native-comp-driver-options '("-Wl,-z,pack-relative-relocs"
                                   "-Wl,-O2"
                                   "-Wl,--as-needed"))


;; Get off my lawn
(let* ((cache-d  (expand-file-name "~/.cache/emacs"))
       (config-d (expand-file-name "~/.config/emacs"))
       (share-d  (expand-file-name "~/.local/share/emacs"))

       (autosave-d (expand-file-name "auto-save-list" cache-d))
       (backups-d (expand-file-name "backups" cache-d))
       (elpa-d (expand-file-name "elpa" share-d))
       (url-d (expand-file-name "url" cache-d)))

  (make-directory url-d t)
  (make-directory elpa-d t)
  (make-directory backups-d t)
  (make-directory autosave-d t)

  (setq user-emacs-directory        cache-d
        package-user-dir            elpa-d
        url-history-file            (expand-file-name "history" url-d)
        custom-file                 (expand-file-name "custom.el" share-d)
        auto-save-list-file-prefix  (expand-file-name ".saves-" autosave-d)
        yas-snippet-dirs            (list (expand-file-name "snippets" config-d))
        treesit-extra-load-path     (list (expand-file-name "tree-sitter" share-d))
        native-comp-eln-load-path   (list (expand-file-name "eln-cache" cache-d))
        backup-directory-alist     `(("." . ,backups-d))))

;; Do now, before it creates the window
(add-to-list 'initial-frame-alist '(height . 51))
(add-to-list 'initial-frame-alist '(width . 120))

;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Rakan Al-Hneiti"
      user-mail-address "rakan.alhneiti@gmail.com")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((gac-debounce-interval . 60)
     (gac-automatically-add-new-files-p . t)
     (gac-automatically-push-p . t))))

;; DOOM CONFIG
(setq doom-theme 'doom-tomorrow-night
      doom-font (font-spec :family "Hack" :size 12)
      display-line-numbers-type t
      projectile-enable-caching t
      projectile-completion-system 'ivy
      projectile-indexing-method 'native
      projectile-sort-order 'recently-active
      counsel-projectile-sort-buffers t
      counsel-projectile-sort-projects t
      counsel-projectile-sort-files t
      counsel-projectile-sort-directories t
      flycheck-rust-check-tests nil
      org-directory "~/Documents/org")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PROJECTILE
(after! projectile
  (require 'f)
  (defun my-projectile-ignore-project (project-root)
    (or
     (f-descendant-of? project-root (expand-file-name "~/.cargo/git"))
     (f-descendant-of? project-root (expand-file-name "~/.cargo/registry"))
     (f-descendant-of? project-root (expand-file-name "~/.rustup")))
  (setq projectile-ignored-project-function #'my-projectile-ignore-project)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ORG MODE
;; Remove TODO keywrods from org-mode (it will still work in agenda)
(after! org
        (set-ligatures! 'org-mode
        :alist '(("TODO " . "")
                ("PROJ" . "")
                ("LOOP" . "")
                ("STRT" . "")
                ("WAIT " . "")
                ("HOLD" . "")
                ("IDEA" . "")
                ("DONE " . "")
                ("KILL" . "")))

        ;; Ellipsis configuration
        (setq org-ellipsis " ▼")

        (after! org-superstar
        ;; Every non-TODO headline now have no bullet
        ; (setq org-superstar-headline-bullets-list '("　"))
        (setq org-superstar-leading-bullet ?　)
        (setq org-superstar-item-bullet-alist
                '((?* . ?•)
                (?+ . ?➤)
                (?- . ?•)))
        ;; Enable custom bullets for TODO items
        (setq org-superstar-special-todo-items t)
        (setq org-superstar-todo-bullet-alist
              '(("TODO" "☐　"  ?☐)
                ("NEXT" "✒　"  ?✒)
                ("STRT" "✰　"  ?✰)
                ("WAIT" "☕　" ?☕)
                ("KILL" "✘　"  ?✘)
                ("DONE" "✔　"  ?✔)))
        ;; (setq org-superstar-todo-bullet-alist
        ;;         '(("TODO" "☐　")
        ;;         ("NEXT" "✒　")
        ;;         ("PROG" "✰　")
        ;;         ("WAIT" "☕　")
        ;;         ("FAIL" "✘　")
        ;;         ("DONE" "✔　")))
        (org-superstar-restart)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; WINDOWS
(map! :leader
      :prefix "w"
      "0" #'delete-window)

(map! :leader
      :prefix "w"
      "1" #'delete-other-windows)

(map! :leader
      :prefix "w"
      "SPC" #'other-window)

(setq evil-split-window-below t)
(setq evil-vsplit-window-right t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SEARCH
(map! :ne "SPC /" #'+default/search-project)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; WHITESPACE MODE
(after! whitespace
  (global-whitespace-mode -1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Terminal
(add-hook! 'vterm-mode-hook
    (add-hook 'doom-switch-window-hook #'evil-insert-state nil 'local))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FLYCHECK
(map! :nv "[e" #'flycheck-previous-error)
(map! :nv "]e" #'flycheck-next-error)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MAGIT
(map! :leader
      :prefix "g"
      :desc "Magit resolve"
      "e" #'magit-ediff-resolve-all)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EVIL-MC
(map! :nv "gzs"
      #'evil-mc-skip-and-goto-next-match)
(map! :nv
      "gzS" #'evil-mc-skip-and-goto-prev-match)
(map! :v "C-n" (general-predicate-dispatch nil ; fall back to nearest keymap
                 (featurep! :editor multiple-cursors)
                 #'evil-mc-make-and-goto-next-match))
(map! :n "C-n" (general-predicate-dispatch nil ; fall back to nearest keymap
                 (and (featurep! :editor multiple-cursors)
                      (bound-and-true-p evil-mc-cursor-list))
                 #'evil-mc-make-and-goto-next-match))
(map! :n "C-S-n" #'evil-mc-make-cursor-move-next-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; PYTHON
(add-hook 'before-save-hook #'py-isort-before-save)
(setq-hook! 'python-mode-hook flycheck-checker 'python-mypy)

;;; LSP
(after! lsp-mode
  (set-popup-rule! "^\\*lsp-help*" :ignore nil :actions: nil :side 'bottom :width 0.5 :quit 'current :select t :vslot 2 :slot 0)
  (setq lsp-rust-server 'rust-analyzer
      lsp-rust-analyzer-server-command "~/.cargo/bin/ra-multiplex"
      lsp-completion-enable t
      lsp-enable-imenu t
      lsp-ui-doc-enable t
      lsp-ui-sideline-code-actions-prefix " "
      lsp-ui-sideline-show-hover t
      lsp-rust-analyzer-server-display-inlay-hints t
      lsp-headerline-breadcrumb-enable t
      lsp-ui-peek-fontify 'always)
  ;; (setq lsp-rust-rustfmt-bin (expand-file-name "~/.cargo/bin/gitfmt"))
  ;; (setq lsp-rust-analyzer-cargo-watch-command "check")
  ;; (set-lookup-handlers! 'lsp-mode :async t
  ;;   :documentation 'lsp-describe-thing-at-point
  ;;   :definition 'lsp-find-definition
  ;;   :references 'lsp-find-references)

  ;; (set-lookup-handlers! 'lsp-ui-mode :async t
  ;;     :definition 'lsp-find-definitions
  ;;     :references 'lsp-ui-peek-find-references)
  ;;
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; RUST
; (setq-hook! 'rustic-mode-hook indent-tabs-mode t)
(setq-hook! 'rustic-mode-hook lsp-rust-rustfmt-path (concat (projectile-project-root) "rustfmt.toml"))
(setq rustic-analyzer-command '("~/.cargo/bin/ra-multiplex"))
(setq rustic-lsp-server 'rust-analyzer)
(setq rustic-format-on-save t)
(setq rustic-lsp-format t)
(setq eldoc-idle-delay 0.5)
;;(setq rustic-rustfmt-bin (expand-file-name "~/.cargo/bin/gitfmt"))
;; (setq-hook! 'rustic-mode-hook counsel-compile-history '("cargo build"))
;; (setq-hook! 'rustic-mode-hook indent-tabs-mode nil)
;; (add-hook 'rustic-mode-hook #'cargo-minor-mode)
;; (add-hook 'rust-mode-hook #'rustic-mode)
(after! rustic
;;   (map! :localleader
;;         :map rustic-mode-map
;;         :prefix "b"
;;         :desc "cargo build"
;;         "c" #'cargo-process-check)

;;   (map! :localleader
;;         :map rustic-mode-map
;;         :prefix "b"
;;         :desc "cargo build"
;;         "b" #'cargo-process-build)

;;   (map! :localleader
;;         :map rustic-mode-map
;;         :prefix "b"
;;         :desc "cargo build"
;;         "r" #'cargo-process-run)
  (map! :localleader
        :map rustic-mode-map
        :prefix "r"
        :desc "cargo check runtime-benchmarks"
        "t" (cmd! (cargo-process--start "Check Tests" "check --features \"runtime-benchmarks\"")))
  (map! :localleader
        :map rustic-mode-map
        :prefix "b"
        :desc "cargo check w/ tests"
        "t" (cmd! (cargo-process--start "Check Tests" "check --tests")))
  (map! :localleader
        :map rustic-compilation-mode-map
        :prefix "["
        :desc "Next Error"
        "[" #'compilation-next-error)
  (map! :localleader
        :map rustic-compilation-mode-map
        :prefix "]"
        :desc "Previous Error"
        "]" #'compilation-previous-error))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Git Auto Commit
(after! git-auto-commit-mode
  (setq gac-automatically-add-new-files-p t
        gac-automatically-push-p t
        gac-silent-message-p t
        gac-commit-additional-flag "-a"))

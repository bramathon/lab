;; .emacs

;; ===================================
;; MELPA Package Support
;; ===================================
(require 'package)

;; Adds the Melpa archive to the list of available repositories
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package delight :ensure t)
(use-package use-package-ensure-system-package :ensure t)

(setq-default
 ad-redefinition-action 'accept                   ; Silence warnings for redefinition
 cursor-in-non-selected-windows t                 ; Hide the cursor in inactive windows
 display-time-default-load-average nil            ; Don't display load average
 fill-column 80                                   ; Set width for automatic line breaks
 help-window-select t                             ; Focus new help windows when opened
 indent-tabs-mode nil                             ; Prefers spaces over tabs
 inhibit-startup-screen t                         ; Disable start-up screen
 initial-scratch-message ""                       ; Empty the initial *scratch* buffer
 kill-ring-max 128                                ; Maximum length of kill ring
 load-prefer-newer t                              ; Prefers the newest version of a file
 mark-ring-max 128                                ; Maximum length of mark ring
 read-process-output-max (* 1024 1024)            ; Increase the amount of data reads from the process
 scroll-conservatively most-positive-fixnum       ; Always scroll by one line
 select-enable-clipboard t                        ; Merge system's and Emacs' clipboard
 tab-width 4                                      ; Set width for tabs
 use-package-always-ensure t                      ; Avoid the :ensure keyword for each package
 vc-follow-symlinks t                             ; Always follow the symlinks
 backup-by-copying t                              ; don't clobber symlinks
 smerge-command-prefix "\C-cv"                    ; Better prefix
 backup-directory-alist '(("." . "~/saves"))      ; Don't litter the filesystem
 view-read-only t)                                ; Always open read-only buffers in view-mode
(cd "~/")                                         ; Move to the user directory
(column-number-mode 1)                            ; Show the column number
(display-time-mode 1)                             ; Enable time in the mode-line
(fset 'yes-or-no-p 'y-or-n-p)                     ; Replace yes/no prompts with y/n
(global-hl-line-mode)                             ; Hightlight current line
(set-default-coding-systems 'utf-8)               ; Default to utf-8 encoding
(show-paren-mode 1)                               ; Show the parent
(delete-selection-mode 1)                         ; Overwrite highlighted text
(setq tramp-default-method "ssh")

(set-face-attribute 'default nil :font "Source Code Pro")
(set-fontset-font t 'latin "Source Code Pro")

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :commands (lsp)
  :config
  (setq lsp-headerline-breadcrumb-enable nil)
  :hook ((python-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration)
         (python-mode-hook . lsp-deferred))
  :custom
  (lsp-prefer-capf t)
  (lsp-restart 'auto-restart)
  (lsp-enable-snippet nil)
  (lsp-prefer-flymake nil))

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package helm-lsp :commands helm-lsp-workspace-symbol)

(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  ;; (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  ;; (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  (define-key lsp-ui-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
  (setq lsp-ui-doc-position 'top
        lsp-ui-imenu-enable t
        lsp-ui-use-webkit 't
        lsp-ui-sideline-enable nil
        lsp-ui-sideline-ignore-duplicate t))

  (setq lsp-completion-provider :capf)

;; Autocompletion
  (use-package company
    :after lsp-mode
    :defer 2
    :diminish
    :custom
    ;;(add-to-list 'company-backends 'company-jedi)
    (company-begin-commands '(self-insert-command))
    (company-idle-delay .1)
    (company-minimum-prefix-length 2)
    (company-show-numbers t)
    (company-tooltip-align-annotations 't)
    (global-company-mode t))

(use-package company-box
  :after company
    :diminish
    :hook (company-mode . company-box-mode))

(use-package doom-themes
  :config (load-theme 'doom-dark+ t))

(use-package doom-modeline
  :defer 0.1
  :config (doom-modeline-mode))

(use-package fancy-battery
  :after doom-modeline
  :hook (after-init . fancy-battery-mode))

(use-package solaire-mode
  :custom (solaire-mode-remap-fringe t)
  :config
  (solaire-mode-swap-bg)
  (solaire-global-mode +1))

(use-package all-the-icons
  :if (display-graphic-p)
  :config (unless (find-font (font-spec :name "all-the-icons"))
        (all-the-icons-install-fonts t)))

(when window-system
  (menu-bar-mode -1)              ; Disable the menu bar
  (scroll-bar-mode -1)            ; Disable the scroll bar
  (tool-bar-mode -1)              ; Disable the tool bar
  ;;(tooltip-mode -1)             ; Disable the tooltips
  )

(use-package helm
  :bind (("M-x" . helm-M-x)
         ("C-x r b" . helm-filtered-bookmarks)
         ("C-x C-f" . helm-find-files))
  :config
  (helm-mode 1)
  )
(use-package helm-tramp
  :bind (("C-c s" . helm-tramp))
  )

(use-package projectile
  :defer 1
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom
  (projectile-completion-system 'helm)
  (projectile-enable-caching t)
  :config (projectile-global-mode))

(use-package treemacs
    :ensure t
    :defer t
    :init
    (with-eval-after-load 'winum
      (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :after (treemacs dired)
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package dockerfile-mode
  :delight "δ "
  :mode "Dockerfile\\'")

(use-package docker
  :bind ("C-c d" . docker))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package which-key
  :defer 0.2
  :delight
  :config (which-key-mode))

(use-package elisp-mode :ensure nil :delight "ξ ")

(use-package blacken
  :delight
  :hook (python-mode . blacken-mode))

(use-package python
  :delight "π "
  :preface
  (defun python-remove-unused-imports()
    "Removes unused imports and unused variables with autoflake."
    (interactive)
    (if (executable-find "autoflake")
        (progn
          (shell-command (format "autoflake --remove-all-unused-imports -i %s"
                                 (shell-quote-argument (buffer-file-name))))
          (revert-buffer t t t))
      (warn "python-mode: Cannot find autoflake executable."))))


(use-package yaml-mode
  :delight "ψ "
  :mode "\\.yml\\'"
  :interpreter ("yml" . yml-mode))

(use-package csv-mode)

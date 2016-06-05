;====================================
;; my emacs settings
;;==================================
;;------------------------------------
;; UI settings
;;------------------------------------

;; disable tool bar
(tool-bar-mode 0)

;; diable menu
;;(menu-bar-mode 0)

;; disable auto save
(auto-save-mode 0)

;; language and locale
(set-language-environment 'UTF-8)
(set-locale-environment "UTF-8") 

;; display line num
(global-linum-mode t)
(setq line-number-mode t)
(setq column-number-mode t)

;; column max
(setq default-fill-column 80)

;; scroll
(setq scroll-margin 0
      scroll-conservatively 1000)

;; default mode is text mode
(setq default-major-mode 'text-mode)

;; don't jump when input ")" or "]" or " }"
(show-paren-mode t)
(setq show-paren-style 'parenthese)

;; highlighter line
(global-hl-line-mode t)

;; yank at guang biao
(setq mouse-yank-at-point t)

;; set kill-ring
(setq kill-ring-max 200)

;; open and display image
(auto-image-file-mode)

;; high light
(global-font-lock-mode t)

;; set startup info
(setq inhibit-startup-message t)

;; use y-n to instead yes-no
(fset 'yes-or-no-p 'y-or-n-p)

;; settings for shell
(setq shell-file-name "/bin/bash")
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

;; windmove
(windmove-default-keybindings)

;; 粘贴时覆盖原有的内容, 而不是插在原有内容之后
(delete-selection-mode 1)

;; 高亮显示末尾空格和超过80列的内容
;; 需要开启 whitespace-mode
;;(global-whitespace-mode 1)
;;(whitespace-mode 1)
;;(setq whitespace-line-column 80)
;;(setq whitespace-style '(face empty tabs lines-tail trailing))

;; key bindings
(when (eq system-type 'darwin) ;; mac specific settings
;  (setq mac-option-modifier 'alt)
  (setq mac-command-modifier 'meta)
  (global-set-key [kp-delete] 'delete-char) ;; sets fn-delete to be right-delete
)

;;------------------------------------
;; function settings
;;------------------------------------
;; emacs plugin directory settings
(add-to-list 'load-path "~/.emacs.d/plugins/")

;;(setq initial-frame-alist '((top . 10) (left . 10) (width . 100) (height . 43)))
;; set backup file
(setq backup-directory-alist (quote (("." . "~/.emacs.d/backupfiles"))))

;; yasnippet
(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet/")
(require 'yasnippet)
(yas-global-mode 1)

;; auto-complete
(add-to-list 'load-path "~/.emacs.d/plugins/auto-complete")
(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t)
(setq-default ac-sources '(ac-source-words-in-same-mode-buffers))
(add-hook 'emacs-lisp-mode-hook (lambda () (add-to-list 'ac-sources 'ac-source-symbols)))
(add-hook 'auto-complete-mode-hook (lambda () (add-to-list 'ac-sources 'ac-source-filename)))
(set-face-background 'ac-candidate-face "lightgray")
(set-face-underline 'ac-candidate-face "darkgray")
(set-face-background 'ac-selection-face "steelblue") ;;; 设置比上面截图中更好看的背景颜色
(define-key ac-completing-map "\M-n" 'ac-next)  ;;; 列表中通过按M-n来向下移动
(define-key ac-completing-map "\M-p" 'ac-previous)
(setq ac-auto-start 2)
(setq ac-dwim t)

;; ibuffer
(require 'ibuffer)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; ido
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

;; smex
;;; Smex
(autoload 'smex "smex"
  "Smex is a M-x enhancement for Emacs, it provides a convenient interface to
your recently and most frequently used commands.")

(global-set-key (kbd "M-x") 'smex)

;; autopair
(require 'autopair)
(autopair-global-mode)

;; open-next-line with C-o
(require 'open-next-line)

;; lisp enviroment
(add-to-list 'load-path "~/.emacs.d/plugins/slime/")  ; your SLIME directory
;; (setq inferior-lisp-program "/usr/bin/sbcl") ; your Lisp system
(setq inferior-lisp-program "/usr/local/bin/sbcl")
(require 'slime)
(slime-setup '(slime-fancy))

;; xcscope
(load-file "~/.emacs.d/plugins/xcscope.el")
(require 'xcscope)
;; auto update cscope database
(setq cscope-do-not-update-database t)

;; htmlize  html export for org-mode (hignlight code)
(require 'htmlize)

;; settings for org mode
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-todo-keywords
      '((sequence "TODO" "DOING" "PENDING" "|" "DONE" "CANCELED")))

(setq org-log-done t)
(setq org-log-done 'time)
;;(setq org-log-done 'note)
(setq org-agenda-files (list "~/gitlocal/mygit/mynote/work/todolist.org"))

;; settings for zen coding
(require 'zencoding-mode)
(add-hook 'sgml-mode-hook 'zencoding-mode) ;; Auto-start on any markup modes

;; settings for yaml mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.raml$" . yaml-mode))

;; settings for pupet mode
(autoload 'puppet-mode "puppet-mode" "Major mode for editing puppet manifests")
(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))


;; settings for emberjs mode
(add-to-list 'load-path "~/.emacs.d/plugins/ember-mode/")
(require 'ember-mode)
(add-hook 'js-mode-hook (lambda () (ember-mode t)))
(add-hook 'multi-web-mode-hook (lambda () (ember-mode t)))

;; cedet settings
(add-to-list 'load-path "~/.emacs.d/plugins/cedet-1.1/common/")
(require 'cedet)
;; Enabling Semantic (code-parsing, smart completion) features
;; Select one of the following:
(semantic-load-enable-minimum-features)
;;(semantic-load-enable-code-helpers)
;;(semantic-load-enable-gaudy-code-helpers)
;;(semantic-load-enable-excessive-code-helpers)
;;(semantic-load-enable-semantic-debugging-helpers)

;; Enable source code folding
(require 'semantic-tag-folding nil 'noerror)
(global-semantic-tag-folding-mode 1)
;; fold/unfold one block
(define-key semantic-tag-folding-mode-map (kbd "C-c , -") 'semantic-tag-folding-fold-block)
(define-key semantic-tag-folding-mode-map (kbd "C-c , =") 'semantic-tag-folding-show-block)
;; fold/unfold all block
(define-key semantic-tag-folding-mode-map (kbd "C-_") 'semantic-tag-folding-fold-all)
(define-key semantic-tag-folding-mode-map (kbd "C-+") 'semantic-tag-folding-show-all)
;; disable/enalble fold function
(global-set-key (kbd "C-?") 'global-semantic-tag-folding-mode)

;;------------------------------------
;; Key bindings
;;------------------------------------
(defun my-cedet-hook ()
  (local-set-key [(control return)] 'semantic-ia-complete-symbol)
  (local-set-key (kbd "C-c /") 'semantic-ia-complete-symbol-menu)
  (local-set-key (kbd "C-c d") 'semantic-ia-fast-jump)
  (local-set-key (kbd "C-c r") 'semantic-symref-symbol)
  (local-set-key (kbd "C-c R") 'semantic-symref))
(add-hook 'c-mode-common-hook 'my-cedet-hook)
;;(defun my-c-mode-cedet-hook ()
  ;; (local-set-key "." 'semantic-complete-self-insert)
  ;; (local-set-key ">" 'semantic-complete-self-insert))
;;(add-hook 'c-mode-common-hook 'my-c-mode-cedet-hook)

;; auto complete
(defun my-indent-or-complete ()
   (interactive)
   (if (looking-at "//>")
          (hippie-expand nil)
          (indent-for-tab-command))
)
 
(global-set-key [(control tab)] 'my-indent-or-complete)
 
(autoload 'senator-try-expand-semantic "senator")
(setq hippie-expand-try-functions-list
          '(
              senator-try-expand-semantic
                   try-expand-dabbrev
                   try-expand-dabbrev-visible
                   try-expand-dabbrev-all-buffers
                   try-expand-dabbrev-from-kill
                   try-expand-list
                   try-expand-list-all-buffers
                   try-expand-line
        try-expand-line-all-buffers
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-whole-kill
        )
)

;; settings for markdown mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; use only one desktop
(setq desktop-path '("~/.emacs.d/"))
(setq desktop-dirname "~/.emacs.d/")
(setq desktop-base-file-name "emacs-desktop")

;; resolve the problem: "desktop file appears to be in use by PID ***"
(setq-default desktop-load-locked-desktop t)

;; remove desktop after it's been read
(add-hook 'desktop-after-read-hook
          '(lambda ()
             ;; desktop-remove clears desktop-dirname
             (setq desktop-dirname-tmp desktop-dirname)
             (desktop-remove)
             (setq desktop-dirname desktop-dirname-tmp)))

(defun saved-session ()
  (file-exists-p (concat desktop-dirname "/" desktop-base-file-name)))

;; use session-restore to restore the desktop manually
(defun session-restore ()
  "Restore a saved emacs session."
  (interactive)
  (if (saved-session)
      (desktop-read)
    (message "No desktop found.")))

;; use session-save to save the desktop manually
(defun session-save ()
  "Save an emacs session."
  (interactive)
  (if (saved-session)
      (if (y-or-n-p "Overwrite existing desktop? ")
          (desktop-save-in-desktop-dir)
        (message "Session not saved."))
    (desktop-save-in-desktop-dir)))

;; use for save window layout
(add-to-list 'load-path "~/.emacs.d/plugins/revive/")
(require 'revive-mode-config)
;; so you can use
;; function "emacs-save-layout" to save current layout to file ~/.layout
;; function "emacs-load-layout" to load last layout from file ~/.layout

;; ask user whether to restore desktop at start-up
(add-hook 'after-init-hook
          '(lambda ()
             (if (saved-session)
                 ;; (if (y-or-n-p "Restore desktop? ")
                     (session-restore))))

(add-hook 'kill-emacs-hook
          '(lambda ()
             (session-save)
             (emacs-save-layout)))

;; js2-mode
;;(autoload 'js2-mode "js2" nil t)
;;(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; go-mode
(add-to-list 'load-path "~/.emacs.d/plugins/go/")
(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)
(require 'go-mode-autoloads)
(add-hook 'before-save-hook 'gofmt-before-save)

(require 'go-autocomplete)
(require 'auto-complete-config)
(ac-config-default)

;(add-hook 'go-mode-hook '(lambda ()
;  (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)))
;
;(add-hook 'go-mode-hook '(lambda ()
;  (local-set-key (kbd "C-c C-g") 'go-goto-imports)))
;
;(add-hook 'go-mode-hook '(lambda ()
;  (local-set-key (kbd "C-c C-f") 'gofmt)))(add-hook 'before-save-hook 'gofmt-before-save)
;
;(add-hook 'go-mode-hook '(lambda ()
;  (local-set-key (kbd "C-c C-k") 'godoc)))

;; espresso-mode for replace js2-mode (js-mode has problem about indent)
;; (add-to-list 'load-path "~/.emacs.d/plugins/")
(autoload 'espresso-mode "espresso" "Start espresso-mode" t)
(add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))

;; emacs for multi web mode(js css php)
(require 'multi-web-mode)
(setq mweb-default-major-mode 'html-mode)
(setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
                  (espresso-mode "<script[^>]*>" "</script>")
                  (css-mode "<style[^>]*>" "</style>")))
(setq mweb-filename-extensions '("hbs" "htm" "html" "php"))
(multi-web-global-mode 1)
(setq sgml-basic-offset 4)

;; settings for nxml indent
(setq nxml-attribute-indent 4)
(setq nxml-child-indent 4)
(setq nxml-outline-child-indent 4)

;; settings for ruby indent
(setq ruby-indent-level 2)

;; auto load flymake
(require 'flymake)
(add-hook 'find-file-hooks 'flymake-find-file-hook)
(setq flymake-gui-warnings-enabled nil)

;; git-emacs settings
(add-to-list 'load-path "~/.emacs.d/plugins/git-emacs/")
(require 'git-emacs)

;; ui color and font
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(column-number-mode t)
 '(ecb-options-version "2.40")
 '(org-agenda-files nil)
 '(scroll-bar-mode (quote right))
 '(send-mail-function (quote mailclient-send-it))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 140 :width normal :foundry "unknown" :family "VL Gothic")))))

;; set chiness font size to look align good at org-mode table
;; ======================================================
;; DejaVu Sans Mono 10 : WenQuanyi Micro Hei Mono 12
;; DejaVu Sans Mono 12 : WenQuanyi Micro Hei Mono 15
;; VL Gothic 12 : WenQuanyi Micro Hei Mono 12  (can't set to bold)
;; ======================================================
(if (and (fboundp 'daemonp) (daemonp))
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (set-fontset-font "fontset-default" 
                                    'unicode "WenQuanyi Micro Hei Mono 14"))))
  (set-fontset-font "fontset-default" 'unicode "WenQuanYi Micro Hei Mono 14"))

;; fix some org-mode + yasnippet conflicts:
(defun yas/org-very-safe-expand ()
  (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))

(add-hook 'org-mode-hook
          (lambda ()
            (make-variable-buffer-local 'yas/trigger-key)
            (setq yas/trigger-key [tab])
            (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
            (define-key yas/keymap [tab] 'yas/next-field)))


;; ecb settings
;; !!! must after the settings of cedet and custom-set-variables !!!
(add-to-list 'load-path "~/.emacs.d/plugins/ecb-2.40/")
;(load-file "~/.emacs.d/plugins/ecb-2.40/ecb.el")
;(require 'ecb)
(setq ecb-auto-activate t
      ecb-tip-of-the-day nil)
(setq stack-trace-on-error t)

;(setq ecb-layout-name "right-ecb")
;; hide/show ecb windows
(define-key global-map [(control f1)] 'ecb-hide-ecb-windows)
(define-key global-map [(control f2)] 'ecb-show-ecb-windows)

;; maximize one of the windows
(define-key global-map (kbd "C-c . 1") 'ecb-maximize-window-methods)
(define-key global-map (kbd "C-c . 2") 'ecb-maximize-window-sources)
(define-key global-map (kbd "C-c . 3") 'ecb-maximize-window-directories)

(define-key global-map (kbd "C-c 1") 'ecb-goto-window-methods)
(define-key global-map (kbd "C-c 2") 'ecb-goto-window-sources)
(define-key global-map (kbd "C-c 3") 'ecb-goto-window-directories)

;; restore window's size
(define-key global-map (kbd "C-c `") 'ecb-restore-default-window-sizes)

;; settings for color-theme
(add-to-list 'load-path "~/.emacs.d/plugins/color-theme-6.6.0/")
(require 'color-theme)
(color-theme-initialize)
(color-theme-deep-blue)

;; settings for send mail
(setq user-full-name "Wang Yubin") 
(setq user-mail-address "wangyb@chujuexinxi.com")


;;------------------------------------
;; key bindings
;;------------------------------------
(global-set-key (kbd "C-<space>") 'set-mark-command)
(global-set-key (kbd "C-,") 'set-mark-command)

;; org-mode 下，替换 C-, 原有功能，使之也和其他mode下一样
(defun org-mode-C-douhao ()
  (define-key org-mode-map (kbd "C-,") 'set-mark-command))
(add-hook 'org-mode-hook 'org-mode-C-douhao)

;;(global-set-key (kbd "C-=") 'set-mark-command)

;; set Alt+k to kill whole line
(global-set-key (kbd "M-k") 'kill-whole-line)

(global-set-key (kbd "M-/") 'hippie-expand)

;; org-mode load export markdown
(eval-after-load "org"
  '(require 'ox-md nil t))

;; set about tab key
(setq-default indent-tabs-mode nil)
;(setq default-tab-width 4)
;(setq tab-width 4)
;; tab and indent width in c base language
(setq c-basic-offset 4)
(setq tab-stop-list ()) 
(setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96))
(global-set-key [C-tab] "\C-q\t")

(defconst my-c-style
  '((c-tab-always-indent        . t)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 4)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t)
    )
  "My C Programming Style")

;; offset customizations not in my-c-style
(setq c-offsets-alist '((member-init-intro . ++)))

;; Customizations for all modes in CC Mode.
(defun my-c-mode-common-hook ()
  ;; add my personal style and set it for the current buffer
  (c-add-style "PERSONAL" my-c-style t)
  ;; other customizations
  (setq tab-width 4
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  ;; we like auto-newline and hungry-delete
  (c-toggle-auto-hungry-state 1)
  ;; key bindings for all supported languages.  We can put these in
  ;; c-mode-base-map because c-mode-map, c++-mode-map, objc-mode-map,
  ;; java-mode-map, idl-mode-map, and pike-mode-map inherit from it.
  (define-key c-mode-base-map (kbd "C-m") 'c-context-line-break)
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;; auto indent
(global-set-key (kbd "RET") 'newline-and-indent)

;; binding F1~F12
(global-set-key (kbd "<f2>") 'speedbar)
;;(global-set-key (kbd "<f5>") 'compile)
;;(global-set-key (kbd "<f6>") 'gdb)
(global-set-key (kbd "<f11>") 'my-fullscreen)
(global-set-key (kbd "<f10>") 'rename-buffer)

;; eshell
(global-set-key (kbd "C-c z") 'eshell)

;; yasnippet
;; (global-set-key (kbd "C-x e") 'yas/expand)

;; etags key
(global-set-key (kbd "M-,") 'pop-tag-mark)
;; (global-set-key (kbd "M-,") 'tags-apropos)

;; switch buffer key
(global-set-key (kbd "M-p") 'bs-cycle-previous)
(global-set-key (kbd "M-n") 'bs-cycle-next)

;; emacs server
(server-start)


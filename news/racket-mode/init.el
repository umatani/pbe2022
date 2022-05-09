;;; init.el --- Initial configuration
;;; Commentary:
;;;   Emacs loads this file for initial configuration.

;;; Code:

(require 'package)
;;(setq package-check-signature nil)  ;; temporary for ver.27
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

;; Download the ELPA archive description if needed.
;; This informs Emacs about the latest versions of all packages, and
;; makes them available for download.
(when (not package-archive-contents)
  (package-refresh-contents))

;; The packages you want installed. You can also install these
;; manually with M-x package-install
;; Add in your own as you wish:
(defvar my-packages
  '(use-package
     ddskk popwin company
     all-the-icons all-the-icons-dired neotree
     flycheck popup flycheck-popup-tip
     ;; for programming languages
     quickrun
     ;;racket-mode
     meghanada
     ;; pos-tip  2021.4.9
     pos-tip
     ))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(require 'use-package)

;; Place downloaded elisp files in ~/.emacs.d/lisp. You'll then be able
;; to load them.
;;
;; For example, if you download yaml-mode.el to ~/.emacs.d/lisp,
;; then you can add the following code to this file:
;;
;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;; 
;; Adding this code will make Emacs enter yaml mode whenever you open
;; a .yml file
(add-to-list 'load-path "~/.emacs.d/lisp")


;;;; 見た目関連

(when window-system
  ;; Emacs開始時に余計なバッファを表示しない
  (setq inhibit-startup-message t)
  (tool-bar-mode -1)
  ;; フォント
  (set-frame-font (cond ((eq window-system 'w32) "Consolas-12")
			((eq window-system 'x) "Ricty Diminished-12")
			(t "Monaco-12")))
  ;; don't pop up font menu
  (global-set-key (kbd "s-t") '(lambda () (interactive)))
  (set-background-color "ivory")
  (setq default-frame-alist
        '((width . 80)
          (height . 26)))
  )

;;; シンタックス・ハイライト
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

;; 行番号を各行に表示
;;(global-linum-mode t)
;; カラム表示
(column-number-mode t)

;;;; popwin
;; (require 'popwin)
;; (setq display-buffer-function 'popwin:display-buffer)
;; (push '(dired-mode :position top) popwin:special-display-config)

;; all-the-icons設定手順
;; (1) M-x all-the-icons-install-fonts
;; (2) (1)で指定したパスに入っているフォントファイルをWindowsに
;;     インストール．たとえば explorer からダブルクリックで開いて
;;    「インストール」ボタンを押す

;; all-the-icons for dired-mode
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

;;;; ナビゲーション関連

;; helm
(use-package helm
  :ensure t
  :init (use-package helm-config)
  :bind (("M-x" . helm-M-x)
         ("M-y" . helm-show-kill-ring)
         ("C-x b" . helm-mini)
         ("C-x C-f" . helm-find-files)
         ("C-c h o" . helm-occur))
  :config
  (progn
    (helm-mode 1)
    ;; rebind tab to do persistent action
    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
    ;; make TAB works in terminal
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
    ;; list actions using C-z
    (define-key helm-map (kbd "C-z")  'helm-select-action)
    (helm-autoresize-mode t)
    (bind-keys
     :map helm-map
     ("C-h" . delete-backward-char))
    (setq helm-M-x-fuzzy-match t ;; optional fuzzy matching for helm-M-x
          helm-buffers-fuzzy-matching t
          helm-recentf-fuzzy-match    t)))

;; dired
;; dired に SKK のキーバインディングを奪われないよう
(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")
            (global-set-key "\C-x\C-j" 'skk-mode)
            ))

;; neotree
;; neotree
(global-set-key "\C-x\C-d" 'neotree-toggle)
(global-set-key "\C-xd" 'neotree-dir)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))



;;;; 日本語関連
(set-language-environment "Japanese")

;;; SKKの設定
;; SKK-JISYO.L
(global-set-key "\C-x\C-j" 'skk-mode)
(global-set-key "\C-xj" 'skk-auto-fill-mode)
(global-set-key "\C-xt" 'skk-tutorial)
;; 理系用句読点
(setq skk-kutouten-type 'en)
;; edict
(setq skk-large-jisyo (expand-file-name "~/.emacs.d/etc/skk/SKK-JISYO.L"))

;; 日本語を C-s (C-r) できるようにする
(add-hook 'isearch-mode-hook
     	  (lambda ()
            (and (boundp 'skk-mode) skk-mode
                 (skk-isearch-mode-setup))
            ;; SKKとは関係ないけど，C-hで検索文字の一文字削除をできるように
            (define-key isearch-mode-map "\C-h" 'isearch-delete-char)))
(add-hook 'isearch-mode-end-hook
     	  (lambda ()
     	    (and (featurep 'skk-isearch) (skk-isearch-mode-cleanup))))

;;;; 編集機能関連

;; \-prefix を使って記号を TeX ライクに入力．
;; M-x set-input-methodで切り替える時のデフォルト選択
(setq default-input-method "TeX")

;; These settings relate to how emacs interacts with your operating system
(setq ;; makes killing/yanking interact with the clipboard
      x-select-enable-clipboard t

      ;; I'm actually not sure what this does but it's recommended?
      x-select-enable-primary t

      ;; Save clipboard strings into kill ring before replacing them.
      ;; When one selects something in another program to paste it into Emacs,
      ;; but kills something in Emacs before actually pasting it,
      ;; this selection is gone unless this variable is non-nil
      save-interprogram-paste-before-kill t

      ;; Shows all options when running apropos. For more info,
      ;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Apropos.html
      apropos-do-all t

      ;; Mouse yank commands yank at point instead of at click.
      mouse-yank-at-point t)


;; M-r で確認なしにバッファを再読み込み
(defun revert-buffer-no-confirm (&optional force-reverting)
  "Interactive call to revert-buffer. Ignoring the auto-save
 file and not requesting for confirmation. When the current buffer
 is modified, the command refuses to revert it, unless you specify
 the optional argument: force-reverting to true."
  (interactive "P")
  ;;(message "force-reverting value is %s" force-reverting)
  (if (or force-reverting (not (buffer-modified-p)))
      (revert-buffer :ignore-auto :noconfirm)
    (error "The buffer has been modified")))
;; reload buffer
(global-set-key "\M-r" 'revert-buffer-no-confirm)

;; Ctrl+H で直前の削除
(global-set-key "\C-h" 'delete-backward-char)

;; 括弧の対応を強調表示
(show-paren-mode t)
;; 現在行に色をつける
;;(global-hl-line-mode t)

;; Emacs can automatically create backup files. This tells Emacs to
;; put all backups in ~/.emacs.d/backups. More info:
;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Backup-Files.html
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))
(setq auto-save-default nil)

;;; 履歴を次回Emacs起動時にも保存する
(savehist-mode 1)
;;; ファイル内のカーソル位置を記憶する
(require 'saveplace)
(save-place-mode 1)

;; タブを使わないでインデント
(setq-default indent-tabs-mode nil)

;; 行へ移動のキーバインド
(global-set-key "\C-x\C-g" 'goto-line)

;; コメントアウト
(global-set-key (kbd "C-c ;") 'comment-region)

;;;; ediff
;; コントロール用のバッファを同一フレーム内に表示
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; diffのバッファを上下ではなく左右に並べる
(setq ediff-split-window-function 'split-window-horizontally)

;; ウィンドウの横幅を超える行を自動で折り返す
(set-default 'truncate-lines nil)


;;;; コーディング関連

;;;; company
;;;;  auto-comletion for all mode
(when (locate-library "company")
  (global-company-mode t)
  (global-set-key (kbd "C-/") 'company-complete)
  ;; (setq company-idle-delay nil) ; 自動補完をしない
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-search-map (kbd "C-n") 'company-select-next)
  (define-key company-search-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map (kbd "C-d") 'company-show-doc-buffer)
  (define-key company-active-map (kbd "M-.") 'company-show-location))

(require 'color)
;; Change company color
;; 未選択項目
(set-face-attribute 'company-tooltip nil
                    :foreground "#666666" :background "#eeeee0")
;; 未選択項目&一致文字
(set-face-attribute 'company-tooltip-common nil
                    :foreground "black" :background "#ddddc8")
;; 選択項目
(set-face-attribute 'company-tooltip-selection nil
                    :foreground "white" :background "#666650")
;; 選択項目&一致文字
(set-face-attribute 'company-tooltip-common-selection nil
                    :foreground "white" :background "#444430")

;; スクロールバー
(set-face-attribute 'company-scrollbar-fg nil
                    :background "#444430")
;; スクロールバー背景
(set-face-attribute 'company-scrollbar-bg nil
                    :background "#888882")
;; アノテーション(型情報)
(set-face-attribute 'company-tooltip-annotation nil
                    :foreground "#444430" :background "#eeeee0")
(set-face-attribute 'company-tooltip-annotation-selection nil
                    :foreground "white" :background "#666650")

;; flycheck
;;(global-flycheck-mode)
(with-eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook 'flycheck-popup-tip-mode))

;;;; プログラミング言語毎の設定

;; ;; Lisp Family
;; (use-package paredit
;;   :ensure t
;;   :config
;;   (dolist (m '(emacs-lisp-mode-hook
;; 	       racket-mode-hook
;; 	       racket-repl-mode-hook))
;;     (add-hook m #'paredit-mode))
;;   (bind-keys :map paredit-mode-map
;; 	     ("{"   . paredit-open-curly)
;; 	     ("}"   . paredit-close-curly))
;;   (unless terminal-frame
;;     (bind-keys :map paredit-mode-map
;; 	       ("M-[" . paredit-wrap-square)
;; 	       ("M-{" . paredit-wrap-curly))))

(add-to-list 'load-path (expand-file-name "~/lib/racket-mode/"))
(require 'racket-mode)
;; racket-modeの追加機能の有効化
(require 'racket-xp)
(add-hook 'racket-mode-hook #'racket-xp-mode)
;; flycheckがあまりにも遅いので無効化
(add-hook 'racket-mode-hook (lambda () (flycheck-mode -1)))


;;;; quickrun
(define-prefix-command 'quickrun-map)
(global-set-key (kbd "C-q") 'quickrun-map)
(define-key 'quickrun-map (kbd "C-q") 'quickrun)
(define-key 'quickrun-map (kbd "C-r") 'quickrun-region)
(define-key 'quickrun-map (kbd "C-a") 'anything-quickrun)
;; ;; quickrun display with popwin
;; (push '("*quickrun*" :height 8) popwin:special-display-config)
;; change default command
;(quickrun-set-default "lisp" "lisp/ccl")

(quickrun-add-command "c++/c11"
                      '((:command . "clang++")
                        (:exec    . ("%c -std=c++11 %o -o %e %s"
                                     "%e %a"))
                        (:remove  . ("%e")))
                      :default "c++")
(quickrun-set-default "c++" "c++/c11")

(quickrun-add-command "runghc"
                      '((:command . "stack runghc")
                        :default "haskell"))
(quickrun-set-default "runghc" "haskell")


;; ここから下は Java の設定

(require 'meghanada)
(add-hook 'java-mode-hook
          (lambda ()
            ;; meghanada-mode on
            (meghanada-mode t)
            (flycheck-mode +1)
            (setq c-basic-offset 2)
            ;; use code format
            (add-hook 'before-save-hook
                      'meghanada-code-beautify-before-save)
            (global-set-key (kbd "M-.") 'meghanada-jump-declaration)
            (global-set-key (kbd "M-,") 'meghanada-back-jump)))
(cond
   ((eq system-type 'windows-nt)
    (setq meghanada-java-path
          (expand-file-name "bin/java.exe" (getenv "JAVA_HOME")))
    (setq meghanada-maven-path "mvn.cmd"))
   (t
    (setq meghanada-java-path "java")
    (setq meghanada-maven-path "mvn")))

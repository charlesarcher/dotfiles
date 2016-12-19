;;General setup
(setq url-proxy-services '(("no_proxy" . "work\\.com")
                           ("http" . "proxy-chain.intel.com:911")))
(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line

(setq gc-cons-threshold 100000000)
(setq inhibit-startup-message t)
(setq compilation-scroll-output t)
(require 'linum)
(global-linum-mode 1)
(add-hook 'find-file-hook (lambda () (linum-mode 1)))
(global-font-lock-mode 1)
(setq linum-format "%4d \u2502")
(column-number-mode 1)

(defalias 'yes-or-no-p 'y-or-n-p)

(defconst demo-packages
  '(anzu
    duplicate-thing
    ggtags
    helm
    helm-gtags
    helm-projectile
    helm-swoop
    function-args
    clean-aindent-mode
    comment-dwim-2
    dtrt-indent
    ws-butler
    iedit
    yasnippet
    smartparens
    projectile
    volatile-highlights
    undo-tree
    zygospore))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package demo-packages)
    (unless (package-installed-p package)
      (package-install package))))

(defun yic-ignore (str)
  (or
   ;;buffers I don't want to switch to
   (string-match "\\*Buffer List\\*" str)
   (string-match "^TAGS" str)
   (string-match "^\\*Messages\\*$" str)
   (string-match "^\\*scratch\\*$" str)
   (string-match "^\\*Completions\\*$" str)
   (string-match-p "^\\*helm.*\\*$" str)
   (string-match "^ " str)
   ;;Test to see if the window is visible on an existing visible frame.
   ;;Because I can always ALT-TAB to that visible frame, I never want to
   ;;Ctrl-TAB to that buffer in the current frame.  That would cause
   ;;a duplicate top-level buffer inside two frames.
   (memq str
         (mapcar
          (lambda (x)
            (buffer-name
             (window-buffer
              (frame-selected-window x))))
          (visible-frame-list)))
   ))

(defun yic-next (ls)
  "Switch to next buffer in ls skipping unwanted ones."
  (let* ((ptr ls)
         bf bn go
         )
    (while (and ptr (null go))
      (setq bf (car ptr)  bn (buffer-name bf))
      (if (null (yic-ignore bn))	;skip over
          (setq go bf)
        (setq ptr (cdr ptr))
        )
      )
    (if go
        (switch-to-buffer go))))

(defun yic-prev-buffer ()
  "Switch to previous buffer in current window."
  (interactive)
  (yic-next (reverse (buffer-list))))

(defun yic-next-buffer ()
  "Switch to the other buffer (2nd in list-buffer) in current window."
  (interactive)
  (bury-buffer (current-buffer))
  (yic-next (buffer-list)))
;;end of yic buffer-switching methods

(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
                (t (self-insert-command (or arg 1)))))
(defun intelligent-close ()
  "quit a frame the same way no matter what kind of frame you are on"
  (interactive)
  (if (eq (car (visible-frame-list)) (selected-frame))
      ;;for parent/master frame...
      (if (> (length (visible-frame-list)) 1)
          ;;close a parent with children present
          (delete-frame (selected-frame))
        ;;close a parent with no children present
        (save-buffers-kill-emacs))
    ;;close a child frame
    (delete-frame (selected-frame))))



(install-packages)

;; this variables must be set before load helm-gtags
;; you can change to any prefix key of your choice
(setq helm-gtags-prefix-key "\C-cg")

(add-to-list 'load-path "~/.emacs.d/custom")

(require 'setup-helm)
(require 'setup-helm-gtags)
(require 'setup-ggtags)
(require 'setup-editing)
;(require 'setup-cedet)

(setq speedbar-use-imenu-flag nil)
(setq sr-speedbar-width 35)
(require 'sr-speedbar)


(windmove-default-keybindings)

;; Available C style:
;; “gnu”: The default style for GNU projects
;; “k&r”: What Kernighan and Ritchie, the authors of C used in their book
;; “bsd”: What BSD developers use, aka “Allman style” after Eric Allman.
;; “whitesmith”: Popularized by the examples that came with Whitesmiths C, an early commercial C compiler.
;; “stroustrup”: What Stroustrup, the author of C++ used in his book
;; “ellemtel”: Popular C++ coding standards as defined by “Programming in C++, Rules and Recommendations,” Erik Nyquist and Mats Henricson, Ellemtel
;; “linux”: What the Linux developers use for kernel development
;; “python”: What Python developers use for extension modules
;; “java”: The default style for java-mode (see below)
;; “user”: When you want to define your own style
(setq
 c-default-style "linux" ;; set style to "linux"
 )

;;(global-set-key (kbd "C-x C-b") 'ibuffer)

(global-set-key (kbd "RET") 'newline-and-indent)  ; automatically indent when press RET

;; activate whitespace-mode to view all whitespace characters
(global-set-key (kbd "C-c w") 'whitespace-mode)

;; show unncessary whitespace that can mess up your diff
(add-hook 'prog-mode-hook (lambda () (interactive) (setq show-trailing-whitespace 1)))

;; use space to indent by default
(setq-default indent-tabs-mode nil)

;; set appearance of a tab that is represented by 4 spaces
(setq-default tab-width 4)

;; Compilation
(global-set-key (kbd "<f5>") (lambda ()
                               (interactive)
                               (setq-local compilation-read-command nil)
                               (call-interactively 'compile)))

;; Stuff
(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)
(global-set-key [\C-home] 'beginning-of-buffer)
(global-set-key [\C-end] 'end-of-buffer)
(global-set-key [\S-tab] 'indent-region)
(global-set-key [?\C-/] 'void) ;forward reference
(global-set-key [\C-backspace] 'backward-kill-word)
(global-set-key "\C-o" 'undo-tree-undo)
(global-set-key "\C-p" 'undo-tree-redo)
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\C-\M-s" 'tags-search)
(global-set-key "\C-x\C-n" 'find-file-other-frame) ;open new frame with a file
(global-set-key "\C-x\C-c" 'intelligent-close) ;forward reference
(global-set-key "\C-x55" 'split-window-fork) ;forward reference
(global-set-key "\M-n" 'scroll-n-lines-ahead) ;forward reference
(global-set-key "\M-p" 'scroll-n-lines-behind) ;forward reference
(global-set-key "\M-u" 'void) ;don't bind upcase word
(global-set-key "\M-l" 'void) ;don't bind downcase word
(global-set-key "\C-c\C-c" 'comment-region) ;have to force it for some reason
(global-set-key "\C-xw" 'what-line)
;;(global-set-key [delete] 'delete-char)
(global-set-key [backspace] 'delete-backward-char)
(global-set-key [f1] 'yic-next-buffer) ;forward reference
(global-set-key [f2] 'yic-prev-buffer) ;forward reference
(global-set-key [f3] 'sr-speedbar-toggle)
(global-set-key [f4] 'query-replace)
;;(global-set-key [f5] 'query-replace-regexp)
(global-set-key [f6] 'isearch-forward)
(global-set-key [f7] 'isearch-backward)
(global-set-key [f8] 'global-linum-mode)
(global-set-key [(shift f3)]  'ggtags-find-other-symbol)
(global-set-key [(shift f4)]  'ggtags-view-tag-history)
(global-set-key [(shift f5)]  'ggtags-find-reference)
(global-set-key [(shift f6)]  'ggtags-find-definition)
(global-set-key [(shift f7)]  'ggtags-create-tags)
(global-set-key [(shift f8)]  'ggtags-update-tags)
(global-set-key [(shift f9)]  'pop-tag-mark)
(global-set-key "\C-xg" 'goto-line)
(global-set-key "\M-g" 'goto-line)
(global-set-key "%" 'match-paren)

;; setup GDB
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )

(load-theme 'solarized t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(frame-background-mode (quote dark)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(linum ((t (:background "yellow" :foreground "gray20" :inverse-video t :underline nil)))))

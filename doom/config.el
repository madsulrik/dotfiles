;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.


;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; =================== CUSTOM ====================
;;

;; (setq evil-snipe-override-evil-repeat-keys nil)
(setq doom-leader-key "SPC")
(setq doom-localleader-key ",")
(setq doom-localleader-alt-key "M-,")


(setq scroll-margin 3)

(map! :nv "C-c i" #'+format/region-or-buffer)
(map! :n "C-s" #'+default/search-buffer)
(map! :n "M" #'consult-imenu)

(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)


;; ;; ================
;; ;;  Zen mode
;; ;; =================

(setq +zen-mixed-pitch-modes '())
(setq +zen-text-scale 1)




(after! writeroom-mode
  (use-package! focus)

  (defun mus/toggle-minor-mode (mode)
    (if (symbol-value mode) (funcall (symbol-function mode) 0) (funcall (symbol-function mode) 1)))

  (defun mus/writeroom-mode-hook ()
    (mus/toggle-minor-mode 'display-line-numbers-mode)
    (mus/toggle-minor-mode 'vi-tilde-fringe-mode)
    (mus/toggle-minor-mode 'focus-mode))

  (add-hook! 'writeroom-mode-hook #'mus/writeroom-mode-hook))



;; ;; ========
;; ;; org mode
;; ;; ========

(setq org-directory "~/Documents/odyssey")
(setq org-roam-directory org-directory)


(after! org


  (setq org-inbox-file
        (expand-file-name "00 inbox.org" org-roam-directory))
  (setq org-sources-file
        (expand-file-name "30 Sources/sources.org" org-roam-directory))
  (setq org-journal-file
        (expand-file-name "10 Chronicles/journal.org" org-roam-directory))

  (setq org-ideas-directory
        (expand-file-name "30 Sources/" org-roam-directory))



  (setq org-capture-templates
        '(
          ("i" "Inbox" entry (file org-inbox-file)
           "* TODO %?\n/Entered on/ %U" :prepend t)
          ("j" "Journal" entry (file+olp+datetree org-journal-file)
           "*  %<%R> %?\n%i" )
          )
        )


  (after! org-roam
    (setq org-roam-capture-templates
          '(("d" "default" plain "%?"
             :target (file+head "%(expand-file-name \"${slug}.org\" org-ideas-directory)"
                                "#+title: ${title}\n")
             :unnarrowed t))))

  (add-to-list 'org-agenda-files org-sources-file)

  )





;; (setq org-capture-templates
;;       '(
;;         ("s" "Source Entry" entry (file org-sources-file)
;;          "* %^{Source/Type|YouTube Video|Article|Book} : %^{Title}\n  :PROPERTIES:\n  :Author: %^{Author}\n  :Date: %^t\n  :Tags: %^{Tags}\n  :Link: %^{Link}\n  :END:\n\n%?")
;;         ))


(

 ;; (setq org-ideas-directory
 ;;       (expand-file-name "20 Ideas" org-roam-directory))
 ;; (setq org-ideas-file
 ;;       (expand-file-name "30 Sources/sources.org" org-roam-directory))

 ;; (setq org-sources-file
 ;;       (expand-file-name "30 Sources/sources.org" org-roam-directory))

 ;; (setq org-roam-capture-templates
 ;;       '(

 ;;         ("i" "inbox" plain ""
 ;;          :target (file+head "inbox.org"
 ;;                             "")
 ;;          :unnarrowed t)


 ;;         ("d" "default" plain "%?"
 ;;          :target (file+head "%(expand-file-name \"${slug}.org\" org-ideas-directory)"
 ;;                             "#+title: ${title}\n")
 ;;          :unnarrowed t)

 ;;         ;;         ("s" "Source Entry" entry (file org-sources-file)
 ;;         ;;          "* %^{Source/Type|YouTube Video|Article|Book} : %^{Title}\n  :PROPERTIES:\n  :Author: %^{Author}\n  :Date: %^t\n  :Tags: %^{Tags}\n  :Link: %^{Link}\n  :END:\n\n%?")

 ;;         ("s" "Sources" plain "%?"
 ;;          :target (file+head "/%<%Y%m%d%H%M%S>-${slug}.org"
 ;;                             "#+title: ${title}\n")
 ;;          :unnarrowed t)
 ;;         ))

 )



;; ;; ================
;; ;; Web mode stuff
;; ;; =================

(after! web-mode
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)

  (map! :map web-mode-map :desc "test" :nv "C-c i" #'web-mode-buffer-indent)
  )

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(".*\\.html\\.erb$" . "html")))


;; ;; ================
;; ;;  JS stuff
;; ;; =================

(after! js2-mode
  (setq js-indent-level 2)
  (setq indent-tabs-mode nil))

(after! rjsx-mode
  (setq js-indent-level 2)
  (setq indent-tabs-mode nil))


;; ;; ================
;; ;;  Ruby stuff
;; ;; =================

(after! ruby-mode
  (defun msc/revert-buffer-noconfirm ()
    "Call `revert-buffer' with the NOCONFIRM argument set."
    (interactive)
    (revert-buffer nil t))

  (defvar rubocop-on-current-file-command "bundle exec rubocop -a "
    "Command to execute to fix current file with rubocop")

  (defun rubocop-on-current-file ()
    "RUBOCOP ON CURRENT_FILE."
    (interactive)
    (save-buffer)
    (message "%s" (shell-command-to-string
                   (concat rubocop-on-current-file-command
                           (shell-quote-argument (buffer-file-name)))))
    (msc/revert-buffer-noconfirm))

  (map! :map ruby-mode-map :desc "Run Rubocop at current file" :nv "C-c i" #'rubocop-on-current-file))



;; ;; ================
;; ;;  Ruby stuff
;; ;; =================

(after! elm-mode

  (defun elm-test-project ()
    "Run the elm-test command on the current project."
    (interactive)
    (let ((default-directory (elm--find-elm-test-root-directory))
          (compilation-buffer-name-function (lambda (_) "*elm-test*")))
      (compile "npx elm-test")))


  (defun elm-test-project-watch ()
    "Run the elm-test command on the current project."
    (interactive)
    (let ((default-directory (elm--find-elm-test-root-directory))
          (compilation-buffer-name-function (lambda (_) "*elm-test*")))
      (compile "npx elm-test --watch")))

  (map! :map elm-mode-map
        :localleader
        (:prefix ("t" . "elm-test")
         :desc "(t)est project" "t" #'elm-test-project
         :desc "(t)est project --(w)atch" "w" #'elm-test-project-watch)))

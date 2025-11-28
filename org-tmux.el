;;; org-tmux.el --- Launch tmux sessions from Org mode headings -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Your Name

;; Author: Your Name <your.email@example.com>
;; Version: 0.1
;; Package-Requires: ((emacs "24.3") (org "8.0"))
;; Keywords: org, tools, terminals
;; URL: https://github.com/your-username/org-tmux

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides functionality to launch tmux sessions from Org mode
;; headings.  It creates a new terminal window attached to a tmux session
;; named after the current Org heading.

;;; Code:

(require 'org)
(require 'ansi-color)

(defgroup org-tmux nil
  "Launch tmux sessions from Org mode headings."
  :group 'org)

(defcustom org-tmux-terminal-command "open"
  "Command to launch the terminal application."
  :type 'string
  :group 'org-tmux)

(defcustom org-tmux-terminal-args '("-n" "-a" "Ghostty" "--args")
  "Arguments passed to `org-tmux-terminal-command'."
  :type '(repeat string)
  :group 'org-tmux)

(defcustom org-tmux-session-property "TMUX_SESSION"
  "Name of the Org property used to store the session ID."
  :type 'string
  :group 'org-tmux)

(defun org-tmux--slug (str)
  "Convert a string STR to a valid session slug (lowercase, hyphens)."
  (let ((s (downcase str)))
    (setq s (replace-regexp-in-string "[^a-z0-9]+" "-" s))
    (replace-regexp-in-string "^-\\|-$" "" s)))

;;;###autoload
(defun org-tmux-launch ()
  "Opens a new terminal window attached to a tmux session for the current Org heading.
The session name is derived from the heading, or can be overridden by
a TMUX_SESSION property."
  (interactive)
  (let* ((heading (org-get-heading t t t t))
         (session-id (or (org-entry-get (point) org-tmux-session-property)
                         (org-tmux--slug heading))))

    (unless (org-entry-get (point) org-tmux-session-property)
      (org-entry-put (point) org-tmux-session-property session-id))
    
    (let ((cmd-args (append org-tmux-terminal-args
                            (list "-e" "tmux" "new-session" "-A" "-s" session-id))))
      (apply #'call-process org-tmux-terminal-command nil 0 nil cmd-args))
    
    (message "Launched terminal session: %s" session-id)))

;;;###autoload
(defun org-tmux-review-history ()
  "Retrieves the history of the linked tmux session and displays it in a colored buffer."
  (interactive)
  (let* ((session-id (org-entry-get (point) org-tmux-session-property))
         (buffer-name (format "*tmux-history:%s*" session-id)))
    
    (unless session-id
      (user-error "No linked %s found for this heading." org-tmux-session-property))

    ;; Create (or clear) the buffer and switch to it
    (with-current-buffer (get-buffer-create buffer-name)
      (let ((inhibit-read-only t))
        (erase-buffer)
        ;; Run the tmux capture command
        (call-process "tmux" nil t nil "capture-pane" "-p" "-e" "-S" "-" "-t" session-id)
        ;; Interpret the ANSI color codes so it looks like a real terminal
        (ansi-color-apply-on-region (point-min) (point-max))
        ;; Make it read-only and enable line wrapping
        (visual-line-mode 1)
        (read-only-mode 1)
        ;; Move to the end so you see the latest output
        (goto-char (point-max))))
    
    (switch-to-buffer-other-window buffer-name)))

;;;###autoload
(eval-after-load 'org-mode
  '(define-key org-mode-map (kbd "C-c t") 'org-tmux-launch))

;;;###autoload
(eval-after-load 'org-mode
  '(define-key org-mode-map (kbd "C-c h") 'org-tmux-review-history))

(provide 'org-tmux)

;;; org-tmux.el ends here

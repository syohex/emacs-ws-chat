;;; ws-chat.el ---

;; Copyright (C) 2012 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL:
;; Version: 0.01

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:


(eval-when-compile
  (require 'cl))

(require 'websocket)

(defgroup ws-chat nil
  "Realtime chat"
  :prefix "ws-chat:")

(defcustom ws-chat:port 5000
  "Port number for Web Application"
  :type 'integer
  :group 'ws-chat)

(defvar ws-chat:websocket)
(defvar ws-chat:chat-buffer "*ws-chat:chat*")
(defvar ws-chat:message-buffer "*ws-chat:message*")

(defun ws-chat:on-message (websocket frame)
  (let ((input (websocket-frame-payload frame)))
    (with-current-buffer (get-buffer-create ws-chat:chat-buffer)
      (goto-char (point-min))
      (insert "\n")
      (goto-char (point-min))
      (insert (decode-coding-string input 'utf-8)))))

(defun ws-chat:create-websocket (url)
  (websocket-open
   url
   :on-message 'ws-chat:on-message
   :on-error (lambda (ws type err)
               (message "error connecting %s" err))
   :on-close (lambda (websocket)
               (setq wstest-closed t))))

(defun ws-chat:init-websocket (port)
  (let ((url (format "ws://0.0.0.0:%d/emacs" port)))
    (message "Connect to %s" url)
    (setq ws-chat:websocket (ws-chat:create-websocket url))))

(defun ws-chat:send-message ()
  (interactive)
  (with-current-buffer (get-buffer-create ws-chat:message-buffer)
    (delete-trailing-whitespace)
    (goto-char (point-max))
    (delete-blank-lines)
    (let ((message (buffer-substring-no-properties
                    (point-min) (point-max))))
     (websocket-send-text ws-chat:websocket message)
     (erase-buffer))))

(defun ws-chat:connect ()
  (interactive)
  (ws-chat:init-websocket ws-chat:port))

(defvar ws-chat:mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'ws-chat:send-message)
    map))

(define-derived-mode ws-chat-mode fundamental-mode
  "WS Chat"
  "mode of WebSocket chat"
  (switch-to-buffer (get-buffer-create ws-chat:chat-buffer))
  (ws-chat:connect)
  (pop-to-buffer (get-buffer-create ws-chat:message-buffer))
  (use-local-map ws-chat:mode-map))

(provide 'ws-chat)

;;; ws-chat.el ends here

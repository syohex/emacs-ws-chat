#!/bin/sh

emacs -Q -nw -l ~/tmp/gomi/emacs-websocket/websocket.el \
    -l ws-chat.el -f ws-chat-mode

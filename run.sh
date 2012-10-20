#!/bin/sh

set -e
set -x

plackup chat.psgi >/dev/null 2>&1 &

sleep 2

emacs -Q -nw -l ~/tmp/gomi/emacs-websocket/websocket.el \
    -l ws-chat.el -f ws-chat-mode

pkill -f plackup

#!/bin/sh

#python3 -m http.server &

while :; do
  inotifywait -e modify lxc-intro.rst
  hovercraft lxc-intro.rst $PWD
done

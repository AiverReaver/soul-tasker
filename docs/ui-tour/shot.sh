#!/bin/sh
# usage: shot.sh NAME  -> shots/full/NAME.png (device px) + shots/NAME.png (393x852, 1px = 1pt)
# SIM=<udid> picks a device when more than one simulator is booted.
case "$1" in ''|*/*|*..*) echo "shot.sh: bad name '$1'" >&2; exit 1;; esac
d=$(cd "$(dirname "$0")" && pwd)
xcrun simctl io "${SIM:-booted}" screenshot --type=png "$d/shots/full/$1.png" >/dev/null 2>&1
sips -z 852 393 "$d/shots/full/$1.png" --out "$d/shots/$1.png" >/dev/null && echo "$d/shots/$1.png"

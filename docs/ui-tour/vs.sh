#!/bin/sh
# usage: vs.sh OUT.png LABEL=IMG [LABEL=IMG ...]
# Puts each image side by side at 393x852 with its label above, one PNG out.
set -e
out=$1; shift
[ $# -ge 2 ] || { echo "vs.sh: need OUT.png and two or more LABEL=IMG" >&2; exit 1; }
page="${TMPDIR:-/tmp}/vs.$$.html"
cols=""
for a in "$@"; do
  label=${a%%=*}; img=${a#*=}
  case "$img" in /*) ;; *) img="$PWD/$img";; esac
  [ -f "$img" ] || { echo "vs.sh: no file $img" >&2; exit 1; }
  cols="$cols<figure><figcaption>$label</figcaption><img src=\"file://$img\"></figure>"
done
printf '<!doctype html><style>body{margin:0;display:flex;gap:12px;background:#222;font:600 14px -apple-system}figure{margin:0}figcaption{color:#eee;padding:6px 0;height:16px}img{width:393px;height:852px;display:block;object-fit:contain;background:#000}</style>%s' "$cols" > "$page"
w=$(( $# * 405 )); h=884
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars \
  --allow-file-access-from-files --force-device-scale-factor=1 --window-size=$w,$h --virtual-time-budget=800 \
  --screenshot="$out" "file://$page" >/dev/null 2>&1
rm -f "$page"
echo "$out"

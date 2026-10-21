#!/bin/sh
# usage: burst.sh PREFIX DELAY1 DELAY2 ... (cumulative-free: each delay is seconds from start)
d=$(cd "$(dirname "$0")" && pwd); p=$1; shift; start=$(python3 -c 'import time;print(time.time())')
i=0; for t in "$@"; do
  python3 -c "import time,sys; s=$start+$t-time.time(); time.sleep(max(0,s))"
  xcrun simctl io "${SIM:-booted}" screenshot --type=png "$d/shots/full/${p}_$i.png" >/dev/null 2>&1 &
  i=$((i+1)); done; wait
for f in "$d"/shots/full/${p}_*.png; do sips -z 852 393 "$f" --out "$d/shots/$(basename $f)" >/dev/null; done; ls "$d"/shots/${p}_*

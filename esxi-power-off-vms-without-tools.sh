#!/bin/sh
set -e

GRACE_PERIOD=3600

for VMID in `vim-cmd vmsvc/getallvms | awk '{ if (NR > 1) print $1 }'`
do
    vim-cmd vmsvc/power.getstate $VMID

    ON=`vim-cmd vmsvc/power.getstate $VMID | grep "Powered on" || EXIT=$?`
    if [[ -n "$ON" ]]; then
        HB=`vim-cmd vmsvc/get.guestheartbeatStatus $VMID`
        if [ "$HB" != "green" ]; then
            UPTIME=`vim-cmd vmsvc/get.summary 259 | sed -rn 's/\ +uptimeSeconds\ =\ ([0-9]+),\ +/\1/p'`
            if [ "$UPTIME" -gt "$GRACE_PERIOD" ]; then
                echo "Powering off VM: $VMID"
                vim-cmd vmsvc/power.off $VMID
            fi
        fi
    fi
done

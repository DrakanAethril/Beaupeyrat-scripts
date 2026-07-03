#!/bin/bash
# Usage: create-group.sh <group> <gid> <nisdomain>

if [ $# -ne 3 ]; then
    echo "Usage: $0 <group> <gid> <nisdomain>"
    exit 1
fi

group="$1"; gid="$2"; nisdomain="$3";

samba-tool group add "$group" \
        --groupou="OU=Groups" \
        --group-scope=Global \
        --gid-number="$gid" \
        --nis-domain="$nisdomain"
if [ $? -ne 0 ]; then
    echo "ERROR: failed to create $group"
    exit 1
fi
echo "Cree: $group (gid=$gid)"
exit 0

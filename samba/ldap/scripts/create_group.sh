#!/bin/bash
# Usage: create-group.sh <group> <gid> <description> <nisdomain>

if [ $# -ne 4 ]; then
    echo "Usage: $0 <group> <gid> <description> <nisdomain>"
    exit 1
fi

group="$1"; gid="$2"; description="$3"; nisdomain="$4";

samba-tool group add "$group" \
        --groupou="OU=Groups" \
        --group-scope=Global \
        --gid-number="$gid" \
        --description="$description" \
        --nis-domain="$nisdomain"

if [ $? -ne 0 ]; then
    echo "ERROR: failed to create $group"
    exit 1
fi
echo "Cree: $group (gid=$gid)"
exit 0

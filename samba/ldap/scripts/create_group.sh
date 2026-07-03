#!/bin/bash
# Usage: create-group.sh <group> <gid>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <group> <gid>"
    exit 1
fi

group="$1"; gid="$2";

samba-tool group add "$group" \
        --groupou="OU=Groups" \
        --group-scope=Global \
        --gid-number="$gid"
    echo "Cree: $group (gid=$gid)"

exit 0

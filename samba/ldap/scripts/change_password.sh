#!/bin/bash
# Usage: change_password.sh <login> <password>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <login> <password>"
    exit 1
fi

login="$1"; password="$2"

samba-tool user setpassword "$login" --newpassword="$password"

if [ $? -ne 0 ]; then
    echo "ERROR: failed to change password for $login"
    exit 1
fi

echo "OK: password changed for $login"
exit 0

#!/bin/bash
# Usage: create-user.sh <firstname> <lastname> <primary_group> <secondary_groups> <login> <uid> <password>
# secondary_groups: vide ("") ou liste separee par |

if [ $# -ne 7 ]; then
    echo "Usage: $0 <firstname> <lastname> <primary_group> <secondary_groups> <login> <uid> <password>"
    echo "       secondary_groups: vide -> \"\" ou liste separee par |"
    exit 1
fi

firstname="$1"; lastname="$2"; primary_group="$3"
secondary_groups="$4"; login="$5"; uid="$6"; password="$7"
DOMAIN="beaupeyrat.lan"
FILESERVER="samba-homes.beaupeyrat.lan"
BASE_OU="OU=People"

declare -A GROUP_GID=(
    [staff-lead]=99105
 #   [support-tech]=99104
 #   [admin]=99103
    [staff]=99102
    [teacher]=99101
    [student]=99100
    [external]=99106
)

gid="${GROUP_GID[$primary_group]}"
if [ -z "$gid" ]; then
    echo "ERROR: unknown primary_group '$primary_group'"
    exit 1
fi

if ! [[ "$uid" =~ ^[0-9]+$ ]]; then
    echo "ERROR: uid '$uid' invalide"
    exit 1
fi

samba-tool user create "$login" "$password" \
    --given-name="$firstname" --surname="$lastname" \
    --userou="$BASE_OU" \
    --uid-number="$uid" --gid-number="$gid" \
    --unix-home="/home/$login" \
    --login-shell="/bin/bash" --mail="$login@$DOMAIN"

if [ $? -ne 0 ]; then
    echo "ERROR: failed to create $login"
    exit 1
fi

samba-tool group addmembers "$primary_group" "$login"

if [ -n "$secondary_groups" ]; then
    IFS='|' read -ra SECGROUPS <<< "$secondary_groups"
    for sg in "${SECGROUPS[@]}"; do
        samba-tool group addmembers "$sg" "$login"
    done
fi

ssh -n root@$FILESERVER \
    "mkdir -p /srv/samba/userdata/$login && \
     chown $uid:$gid /srv/samba/userdata/$login && \
     chmod 0700 /srv/samba/userdata/$login"

echo "OK: $login cree (primary=$primary_group gid=$gid)"
exit 0
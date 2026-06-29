# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

A collection of self-hosted infrastructure automation scripts, organized by service. Currently contains two modules:

- `db-backup/mariadb/` — MariaDB backup script (shell)
- `samba/ldap/manage/` — Samba LDAP management tool (PHP, WIP/empty)

## Running scripts

Scripts are run directly; there is no build step.

```bash
# Run the MariaDB backup manually
bash db-backup/mariadb/mariadb-backup.sh
```

## MariaDB backup script (`db-backup/mariadb/mariadb-backup.sh`)

**Configuration** lives at the top of the script in the `SECTION TO EDIT` block:

- `source /path/to/.env` — must expose `$MYSQL_ROOT_PASSWORD`
- `DOCKERIZED=1` — set to `0` to run commands directly on the host instead of via `docker exec`
- `DOCKER_CONTAINER_NAME` — name of the MariaDB container
- `HOLD_DAYS=7` — number of days of backups to retain; older dated directories under `$BACKUP_DIR` are deleted

**Flow:**
1. `mariadb-check --auto-repair --all-databases` (runs inside the container when `DOCKERIZED=1`)
2. `mkdir -p $BACKUP_DIR/$TIMESTAMP` — creates a dated subdirectory
3. `mariadb-dump --all-databases | gzip > mariadb.gz` — runs inside the container, working directory set to the dated backup folder
4. `find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d -mtime +$HOLD_DAYS -exec rm -rf` — prunes old backups

All docker exec calls use `-d` (detached), so the script does not wait for commands to complete — keep this in mind when adding error checking.

## Samba/LDAP module (`samba/ldap/manage/`)

Still scaffolded/empty. Intended structure:
- `config/config.example` — configuration template (to be filled)
- `tools/function.php` — shared PHP helpers
- `manage_ldap.php` — main entry point

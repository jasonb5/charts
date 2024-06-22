#!/bin/bash

RCLONE_CROND_SCHEDULE="${RCLONE_CROND_SCHEDULE:-0 2 * * *}"
RCLONE_CROND_ARGS="${RCLONE_CROND_ARGS:--d 8}"
RCLONE_USE_RESTIC="${RCLONE_USE_RESTIC:-no}"
RCLONE_RESTORE="${RCLONE_RESTORE:-no}"

function require_env() {
	if [[ -z "${!1}" ]]; then
		echo "Required environment variable ${1} is missing"
		exit 1
	fi
}

require_env RCLONE_SOURCE
require_env RCLONE_DESTINATION

if [[ "${RCLONE_USE_RESTIC}" == "yes" ]]; then
	export RESTIC_REPOSITORY="${RCLONE_DESTINATION}"

	BACKUP_COMMAND="restic ${RCLONE_ARGS} backup ${RCLONE_BACKUP_ARGS} ${RCLONE_SOURCE}"
	RESTORE_COMMAND="restic ${RCLONE_ARGS} restore ${RCLONE_RESTIC_SNAPSHOT:-latest} ${RCLONE_RESTORE_ARGS} --target ${RCLONE_SOURCE}"
else
	BACKUP_COMMAND="rclone sync ${RCLONE_ARGS} ${RCLONE_BACKUP_ARGS} ${RCLONE_SOURCE} ${RCLONE_DESTINATION}"
	RESTORE_COMMAND="rclone sync ${RCLONE_ARGS} ${RCLONE_RESTORE_ARGS} ${RCLONE_DESTINATION} ${RCLONE_SOURCE}"
fi

echo "Backup command: ${BACKUP_COMMAND}"
echo "Restore command: ${RESTORE_COMMAND}"

RESTORE_FILE="${RCLONE_SOURCE}/.restored"

if [[ "${RCLONE_RESTORE}" == "yes" ]]; then
	"${RESTORE_COMMAND}"

	echo `date` >> "${RESTORE_FILE}"
fi

if [[ "${RCLONE_DAEMON:-yes}" == "yes" ]]; then
cat << EOF | crontab -
${RCLONE_CROND_SCHEDULE} ${BACKUP_COMMAND}
EOF

	echo "Starting crond with \"${RCLONE_CROND_ARGS}\""

	crond ${RCLONE_CROND_ARGS}
fi

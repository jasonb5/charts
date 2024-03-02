#!/bin/sh

RESTORE="${RESTORE:-false}"
BACKUP_APP="${BACKUP_APP:-rclone}"

if [[ "${RESTORE}" == "true" ]]; then
	if [[ "${BACKUP_APP}" == "rclone" ]]; then
		rclone ${RCLONE_GLOBAL_FLAGS} sync ${RCLONE_FLAGS} ${RCLONE_SOURCE} ${RCLONE_DESTINATION}
	elif [[ "${BACKUP_APP}" == "restic" ]]; then
		restic -r ${RESTIC_REPO} ${RESTIC_GLOBAL_FLAGS} restore ${RESTIC_SNAPSHOT:-latest} --target ${RESTIC_PATH} ${RESTIC_FLAGS} 
	fi
else
	if [[ "${BACKUP_APP}" == "rclone" ]]; then
		CRON_ENTRY="rclone ${RCLONE_GLOBAL_FLAGS} sync ${RCLONE_FLAGS} ${RCLONE_SOURCE} ${RCLONE_DESTINATION}"
	elif [[ "${BACKUP_APP}" == "restic" ]]; then
		CRON_ENTRY="restic -r ${RESTIC_REPO} ${RESTIC_GLOBAL_FLAGS} backup ${RESTIC_FLAGS} ${RESTIC_PATH}"
	fi

	if [[ -n "${PRE_SCRIPT}" ]] && [[ -e "${PRE_SCRIPT}" ]]; then
		CRON_ENTRY="${PRE_SCRIPT}; ${CRON_ENTRY}"
	fi

	if [[ -n "${POST_SCRIPT}" ]] && [[ -e "${POST_SCRIPT}" ]]; then
		CRON_ENTRY="${CRON_ENTRY}; ${POST_SCRIPT}"
	fi

	echo "Adding cron entry \"${CRON} ${CRON_ENTRY}\""

cat << EOF | crontab -
${CRON} ${CRON_ENTRY}
EOF

	CROND_ARGS="-f ${CROND_ARGS:--d 8}"

	echo "Running crond with \"${CROND_ARGS}\""

	crond ${CROND_ARGS}
fi

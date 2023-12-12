#!/bin/sh

if [[ -n "${CUSTOM_COMMAND}" ]];
then
	CRON_ENTRY="${CUSTOM_COMMAND}"
else
	CRON_ENTRY="rclone sync ${SOURCE} ${DESTINATION}"
fi


if [[ -n "${PREPARE_SCRIPT}" ]] && [[ -e "${PREPARE_SCRIPT}" ]];
then
	CRON_ENTRY="${PREPARE_SCRIPT}; ${CRON_ENTRY}"
fi

if [[ -n "${FLAGS}" ]];
then
	CRON_ENTRY="${CRON_ENTRY} ${FLAGS}"
fi

echo "Adding cron entry \"${CRON} ${CRON_ENTRY}\""

cat << EOF | crontab -
${CRON} ${CRON_ENTRY}
EOF

CROND_ARGS="-f ${CROND_ARGS:--d 8}"

echo "Running crond with \"${CROND_ARGS}\""

crond ${CROND_ARGS}

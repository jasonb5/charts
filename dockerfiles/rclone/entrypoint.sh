echo "Creating cron entry using \"${CRON}\" schedule"
echo "Syncing \"${SOURCE}\" -> \"${DESTINATION}\""
echo "Using \"${FLAGS}\" for sync command"

cat << EOF | crontab -
${CRON} rclone sync ${SOURCE} ${DESTINATION} ${FLAGS}
EOF

CROND_ARGS=${CROND_ARGS:-"-d 8"}

crond -f ${CROND_ARGS}

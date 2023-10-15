echo "Creating cron entry using \"${CRON}\" schedule"
echo "Syncing \"${SOURCE}\" -> \"${DESTINATION}\""
echo "Using \"${FLAGS}\" for sync command"

cat << EOF | crontab -
${CRON} rclone sync ${SOURCE} ${DESTINATION} ${FLAGS}
EOF

exec $@

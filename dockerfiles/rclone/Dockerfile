FROM alpine:3.18.4

RUN apk add rclone tini && \
	mkdir -p /root/.config/rclone && \
	touch /root/.config/rclone/rclone.conf

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "-g"]

CMD ["/bin/sh", "/entrypoint.sh", "crond", "-f"]

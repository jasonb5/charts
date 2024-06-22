FROM alpine:3.18.4

ENV VERSION=0.1.3

RUN apk add rclone restic tini bash

COPY entrypoint.sh /entrypoint.sh

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["tini", "-g"]

CMD ["/bin/bash", "/entrypoint.sh"]

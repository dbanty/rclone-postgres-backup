# syntax=docker/dockerfile:1

FROM rclone/rclone:1.70.3 AS rclone

FROM alpine:3

RUN apk add --update --no-cache postgresql17-client bash

COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

WORKDIR /backup

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PGPORT="5432"
ENV R2_PATH="postgres-backup.tar"

CMD ["/entrypoint.sh"]

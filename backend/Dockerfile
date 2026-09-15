FROM alpine:3.24

RUN apk add --no-cache bash sqlite iputils

WORKDIR /app

COPY network-watcher.sh .
RUN chmod +x network-watcher.sh

VOLUME /data

CMD ["./network-watcher.sh"]

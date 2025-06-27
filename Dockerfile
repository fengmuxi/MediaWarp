FROM golang:1.24 AS builder
ENV GO111MODULE=on \
    GOPROXY=https://goproxy.io,direct \
    CGO_ENABLED=0

WORKDIR /builder
COPY . .
RUN go mod download && \
    go build -ldflags " \
    -s -w \
    -X MediaWarp/internal/config.commitHash=c92be77341e8f134b5b2c5b0d0e9e73f2a72ad9a \
    -X MediaWarp/internal/config.buildDate=2025-06-27 17:10:00" \
    -o MediaWarp

FROM alpine:latest
COPY --from=builder /builder/MediaWarp /MediaWarp

RUN chmod +x /MediaWarp

EXPOSE 9000
VOLUME ["/etc/localtime", "/etc/timezone", "/config", "/logs", "/custom"]
ENTRYPOINT ["/MediaWarp"]

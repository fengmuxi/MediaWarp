# 阶段1: 构建应用
FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 启用 Go Modules 并加速下载
ENV GOPROXY=https://goproxy.cn,direct

# 复制依赖文件并安装（利用Docker缓存层）
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# 复制全部代码
COPY . .

# 构建静态链接的可执行文件（适合Alpine）
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags='-w -s' -a -o /MediaWarp

# 阶段2: 最小化生产镜像
FROM alpine:latest

# 从构建阶段复制二进制文件
COPY --from=builder /MediaWarp /app/MediaWarp

# 设置非root用户运行
RUN adduser -D -u 1000 MediaWarp
USER MediaWarp

# 暴露端口（可选）
EXPOSE 9000

# 启动应用
CMD ["/app/MediaWarp"]
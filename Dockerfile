FROM golang:1.22.1-alpine3.19 AS builder
WORKDIR /home
ADD . .
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o terraform-provider-alicloud/bin/terraform-provider-alicloud github.com/aliyun/terraform-provider-alicloud && \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add --no-cache git ca-certificates && \
    update-ca-certificates && \
    git config --global http.version HTTP/1.1 && \
    git config --global http.sslVerify "false" && \
    git config --global http.postBuffer 1024288000 && \
    git config --global http.lowSpeedLimit 0 && \ 
    git config --global http.lowSpeedTime 999999 && \
    git clone http://github.com/hashicorp/terraform.git && \
    cd terraform && \
    go build
 
FROM alpine:3.11.6
WORKDIR /home
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add --no-cache ca-certificates && \
    update-ca-certificates
COPY --from=builder /home/terraform-provider-alicloud/bin/terraform-provider-alicloud .
COPY --from=builder /home/terraform/terraform /usr/bin/
# 写成 COPY ./debug/.terraformrc ~/ 会将文件放到 /home/~/.terraformrc
COPY ./debug/.terraformrc .
RUN  mv /home/.terraformrc ~
COPY ./debug/main.tf .
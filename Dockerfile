############################
# STEP 1 build executable binary
############################
FROM golang AS builder
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GO111MODULE=on
RUN apt update && apt install -y git bash wget
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/LibCyber/VNet-V2ray.git /usr/local/go/src/github.com/LibCyber/VNet-V2ray
RUN  cd  /usr/local/go/src/github.com/LibCyber/VNet-V2ray && \
    go build -o bin/linux/vnet-v2ray -compiler gc -gcflags "all=-trimpath=${GOPATH}/src" -asmflags "all=-trimpath=${GOPATH}/src" -ldflags '-s -w' -tags '' v2ray.com/core/vnet

############################
# STEP 2 build a small image
############################
FROM alpine:3.8
COPY --from=builder /usr/local/go/src/github.com/LibCyber/VNet-V2ray/bin/linux/vnet-v2ray /usr/bin/vnet-v2ray

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}
ENV API_HOST=http://baidu.com \
    KEY=geptpxzp8zwdatc5 \
    NODE_ID=1

RUN apk upgrade --update \
    && apk add bash tzdata \
    && apk add ca-certificates \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/cache/apk/*

CMD /usr/bin/vnet-v2ray --api_host ${API_HOST} --key ${KEY} --node_id ${NODE_ID}
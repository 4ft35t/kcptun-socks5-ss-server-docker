# kcp-server & shadowsocks-libev for Dockerfile
FROM alpine:latest
MAINTAINER cnDocker

ENV CONF_DIR="/usr/local/conf"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                tar \
                                shadowsocks-libev && \

    cd /tmp && \
    KCP_URL="https://github.com/$(curl https://github.com/xtaci/kcptun/releases/latest -L | grep -Eo '/xtaci.+linux-amd64.+tar.gz' | head -1)" && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    curl -sSL ${KCP_URL} | tar xz && \
    mv server_linux_amd64 /usr/bin/kcp-server && \

    apk del .build-deps && \
    rm -rf /tmp/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

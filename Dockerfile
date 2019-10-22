# kcp-server & shadowsocks-libev for Dockerfile
FROM alpine:latest
MAINTAINER cnDocker

ENV CONF_DIR="/usr/local/conf"

RUN set -ex && \
    apk add --no-cache --virtual .run-deps \
                                curl \
                                shadowsocks-libev && \

    cd /tmp && \
    KCP_URL="https://github.com/$(curl https://github.com/xtaci/kcptun/releases/latest -L | grep -Eo '/xtaci.+linux-amd64.+tar.gz' | head -1)" && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    curl -sSL ${KCP_URL} | tar xz && \
    mv server_linux_amd64 /usr/bin/kcp-server && \

    rm -rf /tmp/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

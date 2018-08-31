# kcp-server & shadowsocks-libev for Dockerfile
FROM alpine:latest
MAINTAINER cnDocker

ARG SS_URL="https://github.com"`curl https://github.com/shadowsocks/shadowsocks-libev/releases/latest -L |grep -Eo "/shadowsocks/shadowsocks-libev/release.*?.tar.gz"`

ENV CONF_DIR="/usr/local/conf"

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                autoconf \
                                build-base \
                                curl \
                                libev-dev \
                                libtool \
                                linux-headers \
                                udns-dev \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                tar \
                                udns-dev && \

    cd /tmp && \
    curl -sSL $SS_URL | tar xz --strip 1 && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd .. && \

    cd /tmp && \
    KCP_URL="https://github.com/"`curl https://github.com/xtaci/kcptun/releases/latest -L | grep -Eo '/xtaci.+linux-amd64.+tar.gz' | head -1` && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    curl -sSL ${KCP_URL} | tar xz && \
    mv server_linux_amd64 /usr/bin/kcp-server && \

    runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \

    apk add --no-cache --virtual .run-deps bash $runDeps && \
    apk del .build-deps && \
    rm -rf shadowsocks-libev /tmp/* 

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

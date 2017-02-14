# kcp-server & shadowsocks-libev for Dockerfile
FROM alpine:latest
MAINTAINER cnDocker
# 替换阿里云源
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories

ENV CONF_DIR="/usr/local/conf" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN set -ex && \
    apk add --no-cache  --virtual TMP autoconf automake build-base curl libtool linux-headers udns-dev libsodium-dev mbedtls-dev pcre-dev udns-dev && \
    SS_URL="https://github.com"`curl https://github.com/shadowsocks/shadowsocks-libev/releases | grep -Eo '/shadowsocks.+archive.+tar.gz' | head -1` && \
    KCP_URL="https://github.com/"`curl https://github.com/xtaci/kcptun/releases/latest -L | grep -Eo '/xtaci.+linux-amd64.+tar.gz' | head -1` && \
    curl -sSL ${SS_URL} | tar xz && \
    cd  shadowsocks-libev* && \
    ./autogen.sh && ./configure --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf shadowsocks-libev* && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    [ ! -d ${KCPTUN_DIR} ] && mkdir -p ${KCPTUN_DIR} && cd ${KCPTUN_DIR} && \
    curl -sSL ${KCP_URL} | tar xz && \
    mv ${KCPTUN_DIR}/server_linux_amd64 ${KCPTUN_DIR}/kcp-server && \
    rm -f ${KCPTUN_DIR}/client_linux_amd64 ${KCPTUN_DIR}/${kcptun_latest_filename} && \
    chown root:root ${KCPTUN_DIR}/* && \
    chmod 755 ${KCPTUN_DIR}/* && \
    ln -s ${KCPTUN_DIR}/* /bin/ && \
    apk --no-cache del --virtual TMP && \
    apk --no-cache del build-base autoconf && \
    rm -rf /var/cache/apk/* ~/.cache /tmp/libsodium

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


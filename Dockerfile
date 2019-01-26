FROM alpine:3.8

ARG STUNNEL_VERSION
ARG IMAGE_VERSION

ARG BUILD_DATE
ARG VCS_REF

RUN set -x \
 && addgroup -S stunnel \
 && adduser -S -G stunnel stunnel \
 && apk update \
 && apk add --update --no-cache \
        ca-certificates \
        gettext \
        libintl \
        openssl-dev \
        wget \
        build-base \
        linux-headers \
        openssl \
 && cp -v /usr/bin/envsubst /usr/local/bin/ \
 && apk del --purge gettext \
 && mkdir -p /tmp/src \
 && cd /tmp/src \
 && wget https://www.stunnel.org/downloads/stunnel-${STUNNEL_VERSION}.tar.gz \
 && tar -zxvf stunnel-${STUNNEL_VERSION}.tar.gz \
 && cd stunnel-${STUNNEL_VERSION} \
 && ./configure \
 && make \
 && make install \
 && apk del --purge \
         openssl-dev \
         wget \
         build-base \
         linux-headers \
 && rm -rf /var/cache/apk /tmp/src \
 && apk --no-network info openssl

COPY *.template openssl.cnf /srv/stunnel/
COPY entrypoint.sh /srv/

RUN set -x \
 && chmod +x /srv/entrypoint.sh \
 && mkdir -p /var/run/stunnel /etc/stunnel \
 && chown -vR stunnel:stunnel /var/run/stunnel

ENTRYPOINT ["/srv/entrypoint.sh"]
CMD ["stunnel", "/etc/stunnel/stunnel.conf"]

LABEL \
    org.label-schema.vendor="Inveniem - Guy Elsmore-Paddock" \
    org.label-schema.url="https://github.com/guypaddock/stunnel" \
    org.label-schema.name="STunnel Docker Container" \
    org.label-schema.version=$IMAGE_VERSION \
    org.label-schema.vcs-url="https://github.com/guypaddock/stunnel.git" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license="MIT" \
    org.label-schema.schema-version="1.0"

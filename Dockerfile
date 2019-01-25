FROM alpine:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.label-schema.vendor="The Goofball - goofball222@gmail.com" \
    org.label-schema.url="https://github.com/goofball222/stunnel" \
    org.label-schema.name="STunnel Docker Container" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com/goofball222/stunnel.git" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license="MIT" \
    org.label-schema.schema-version="1.0"

RUN set -x \
 && addgroup -S stunnel \
 && adduser -S -G stunnel stunnel \
 && apk add --update --no-cache \
        ca-certificates \
        gettext \
        libintl \
        openssl \
        stunnel \
 && cp -v /usr/bin/envsubst /usr/local/bin/ \
 && apk del --purge \
        gettext \
 && apk --no-network info openssl \
 && apk --no-network info stunnel
COPY *.template openssl.cnf /srv/stunnel/
COPY stunnel.sh /srv/

RUN set -x \
 && chmod +x /srv/stunnel.sh \
 && mkdir -p /var/run/stunnel /var/log/stunnel \
 && chown -vR stunnel:stunnel /var/run/stunnel /var/log/stunnel \
 && mv -v /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.original

ENTRYPOINT ["/srv/stunnel.sh"]
CMD ["stunnel"]

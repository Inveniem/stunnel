#!/bin/sh -e

# Initialize all STUNNEL_ environment variables to good defaults.
export STUNNEL_CONF="/etc/stunnel/stunnel.conf"
export STUNNEL_DEBUG="${STUNNEL_DEBUG:-5}"

export STUNNEL_CLIENT="${STUNNEL_CLIENT:-no}"

export STUNNEL_PSK="${STUNNEL_PSK:-}"

export STUNNEL_CAFILE="${STUNNEL_CAFILE:-/etc/ssl/certs/ca-certificates.crt}"
export STUNNEL_VERIFY_CHAIN="${STUNNEL_VERIFY_CHAIN:-no}"
export STUNNEL_VERIFY_PEER="${STUNNEL_VERIFY_PEER:-no}"
export STUNNEL_KEY="${STUNNEL_KEY:-/etc/stunnel/stunnel.key}"
export STUNNEL_CRT="${STUNNEL_CRT:-/etc/stunnel/stunnel.pem}"

# "Modern" Ciphers according to Mozilla's SSL Configuration Generator
# See: https://ssl-config.mozilla.org/
export STUNNEL_CIPHERS="${STUNNEL_CIPHERS:-TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256}"

if [ -z "${STUNNEL_SERVICE}" ] || [ -z "${STUNNEL_ACCEPT}" ] || \
   [ -z "${STUNNEL_CONNECT}" ]; then
    {
        echo "one or more STUNNEL_* values missing: "
        echo "  STUNNEL_SERVICE=${STUNNEL_SERVICE}"
        echo "  STUNNEL_ACCEPT=${STUNNEL_ACCEPT}"
        echo "  STUNNEL_CONNECT=${STUNNEL_CONNECT}"
    } >&2
    exit 1
fi

if [ -n "${STUNNEL_PSK}" ]; then
    if [ ! -f "${STUNNEL_PSK}" ]; then
        echo >&2 "STUNNEL_PSK (${STUNNEL_PSK}) must point to an existing file"
        exit 1
    fi

    TEMPLATE_SRC="stunnel.conf.psk.template"
else
    if [ "${STUNNEL_CLIENT}" = "yes" ]; then
        TEMPLATE_SRC="stunnel.conf.pki-client.template"
    else
        if [ ! -f "${STUNNEL_KEY}" ]; then
            if [ -f "${STUNNEL_CRT}" ]; then
                echo >&2 "crt (${STUNNEL_CRT}) missing key (${STUNNEL_KEY})"
                exit 1
            fi

            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout "${STUNNEL_KEY}" \
                -out "${STUNNEL_CRT}" \
                -config /srv/stunnel/openssl.cnf
        fi

        cp -v "${STUNNEL_CRT}" /usr/local/share/ca-certificates/stunnel.crt

        TEMPLATE_SRC="stunnel.conf.pki-server.template"
    fi

    cp -v "${STUNNEL_CAFILE}" /usr/local/share/ca-certificates/stunnel-ca.crt

    # Update certificates but ignore "does not contain exactly one
    # certificate or CRL" warning
    update-ca-certificates 2>/dev/null
fi

envsubst <"/srv/stunnel/${TEMPLATE_SRC}" >${STUNNEL_CONF}

exec "$@"

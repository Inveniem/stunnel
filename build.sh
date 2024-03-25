#!/usr/bin/env bash

source version.env

docker build \
    --build-arg "IMAGE_VERSION=${IMAGE_VERSION}" \
    --build-arg "STUNNEL_VERSION=${STUNNEL_VERSION}" \
    -t "inveniem/stunnel:${IMAGE_VERSION}" \
    .

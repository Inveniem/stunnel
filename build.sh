#!/usr/bin/env bash

source version.env

##
# Detects what commit of this project is checked-out.
#
# This information is exported to REPO_VCS_REF so it can be stamped into the
# docker image.
#
detect_repo_commit() {
  declare -g REPO_VCS_REF

  REPO_VCS_REF=$(git rev-parse --short HEAD)
}

detect_repo_commit

docker build \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg "VCS_REF=${REPO_VCS_REF}" \
    --build-arg "IMAGE_VERSION=${IMAGE_VERSION}" \
    --build-arg "STUNNEL_VERSION=${STUNNEL_VERSION}" \
    -t "inveniem/stunnel:${IMAGE_VERSION}" \
    .

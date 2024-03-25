#!/usr/bin/env bash

tags=(
    "latest"
    "stable"
    "5.72"
    "5"
)

for tag in "${tags[@]}"; do
    docker tag "inveniem/stunnel:${1}" "inveniem/stunnel:${tag}"
    docker push "inveniem/stunnel:${tag}"
done

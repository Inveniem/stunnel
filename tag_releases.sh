#!/usr/bin/env bash

tags=(
    "latest"
    "stable"
    "5.50"
    "5"
)

for tag in "${tags[@]}"; do
    docker tag "guyelsmorepaddock/stunnel:${1}" "guyelsmorepaddock/stunnel:${tag}"
    docker push "guyelsmorepaddock/stunnel:${tag}"
done

#!/usr/bin/env bash

musl_cc_()
{
    local BASE_FOLDER="${HOME}/musl-cc"
    local BASE_URL="https://musl.cc"

    mkdir -p "${BASE_FOLDER}"
    cd "${BASE_FOLDER}"

    # Filtrar directamente las URLs que contienen 'cross' y terminan en '.tgz'
    local links
    links=$(curl -sL "${BASE_URL}/" | grep 'cross.*\.tgz$')

    # La variable links ya contiene las URLs completas
    for target_url in ${links}; do
        if wget -q --spider "${target_url}"; then
            wget --https-only --inet4-only -c "${target_url}"
        else
            echo "Error: Enlace inaccesible -> ${target_url}" >&2
        fi
    done
}

musl_cc_

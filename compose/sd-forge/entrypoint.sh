#!/usr/bin/env bash

pushd /app/stable-diffusion-webui || exit 1
./webui.sh "$@"
popd || exit 1

#!/usr/bin/env bash

if [ -z "$(find /app/entrypoint.d -maxdepth 1 -type f  -name \"*.sh\" 2>/dev/null)" ]; then
    for file in /entrypoint.d/*.sh; do
    	chmod +x ${file} || true;
    done
fi
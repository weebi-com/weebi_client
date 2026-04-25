#!/bin/sh
# API_URL is set at build time (--build-arg API_URL=...) per env. We still write config.json for optional use.
# See SECRETS.md for build-arg and CI setup.

CONFIG_FILE="/usr/share/nginx/html/config.json"
LOCALE="${LOCALE:-fr}"
echo "{\"API_URL\":\"\",\"LOCALE\":\"${LOCALE}\"}" > "$CONFIG_FILE"
exec nginx -g "daemon off;"

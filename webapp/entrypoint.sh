#!/bin/sh
set -eu

CONFIG_FILE="/usr/share/nginx/html/config.json"
NGINX_TEMPLATE="/etc/nginx/templates/default.conf.template"
NGINX_CONFIG="/etc/nginx/conf.d/default.conf"

PORT="${PORT:-8080}"
API_URL="${API_URL:-}"
LOCALE="${LOCALE:-fr}"
IS_BFF_MODE="${IS_BFF_MODE:-true}"

sed "s/__PORT__/${PORT}/g" "$NGINX_TEMPLATE" > "$NGINX_CONFIG"
printf '{"API_URL":"%s","LOCALE":"%s","IS_BFF_MODE":"%s"}\n' "$API_URL" "$LOCALE" "$IS_BFF_MODE" > "$CONFIG_FILE"

exec nginx -g "daemon off;"

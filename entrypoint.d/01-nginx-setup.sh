#!/usr/bin/env sh

# Exit the script if any statement returns a non-true return value
set -e
rm -f /etc/nginx/sites-enabled/default
/usr/local/bin/go-replace --regex -s '\bSERVICE_NAME\b' -r ${SERVICE_NAME} /etc/nginx/sites-enabled/app.conf

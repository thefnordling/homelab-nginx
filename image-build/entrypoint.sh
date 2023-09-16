#!/bin/bash
set -e
/get-certificates.sh &
sleep 10
exec /docker-entrypoint.sh nginx -g "daemon off;"
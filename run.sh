#!/usr/bin/env bash
set -e

echo "Starting OCPP 2-Way Proxy..."

# Read configuration from Home Assistant
CONFIG_PATH="/data/options.json"

# Check if jq is available, if not install it
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    apk add --no-cache jq
fi

# Extract configuration values using jq
LOG_LEVEL=$(jq -r '.log_level // "INFO"' $CONFIG_PATH)
LOG_LEVEL_WS_CLIENT=$(jq -r '.log_level_websockets_client // "INFO"' $CONFIG_PATH)
LOG_LEVEL_WS_SERVER=$(jq -r '.log_level_websockets_server // "INFO"' $CONFIG_PATH)
HOST_ADDR=$(jq -r '.host_addr // "0.0.0.0"' $CONFIG_PATH)
HOST_PORT=$(jq -r '.host_port // 8321' $CONFIG_PATH)
WATCHDOG_STALE=$(jq -r '.watchdog_stale // 500' $CONFIG_PATH)
WATCHDOG_INTERVAL=$(jq -r '.watchdog_interval // 100' $CONFIG_PATH)
PING_TIMEOUT=$(jq -r '.ping_timeout // 60' $CONFIG_PATH)
PRIMARY_SERVER=$(jq -r '.primary_server // "ws://ocpp.example.com:80"' $CONFIG_PATH)
SECONDARY_SERVER=$(jq -r '.secondary_server // ""' $CONFIG_PATH)

# Generate configuration file
cat > /app/ocpp-2w-proxy.ini <<EOF
[logging]
proxy = ${LOG_LEVEL}
websockets.client = ${LOG_LEVEL_WS_CLIENT}
websockets.server = ${LOG_LEVEL_WS_SERVER}

[host]
addr = ${HOST_ADDR}
port = ${HOST_PORT}
watchdog_stale = ${WATCHDOG_STALE}
watchdog_interval = ${WATCHDOG_INTERVAL}
ping_timeout = ${PING_TIMEOUT}

[ext-server]
server = ${PRIMARY_SERVER}
EOF

# Add secondary server only if configured
if [ -n "${SECONDARY_SERVER}" ]; then
    echo "secondary_server = ${SECONDARY_SERVER}" >> /app/ocpp-2w-proxy.ini
fi

echo "Configuration:"
echo "  Primary Server: ${PRIMARY_SERVER}"
if [ -n "${SECONDARY_SERVER}" ] && [ "${SECONDARY_SERVER}" != "null" ]; then
    echo "  Secondary Server: ${SECONDARY_SERVER}"
else
    echo "  Secondary Server: Not configured (1-way mode)"
fi
echo "  Listening on: ${HOST_ADDR}:${HOST_PORT}"
echo ""
echo "Generated configuration file:"
cat /app/ocpp-2w-proxy.ini
echo ""

# Start the application
python3 /app/ocpp-2w-proxy.py

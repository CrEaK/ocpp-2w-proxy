#!/usr/bin/env bashio

# Read configuration from Home Assistant
CONFIG_PATH="/data/options.json"

# Extract configuration values
LOG_LEVEL=$(bashio::config 'log_level')
LOG_LEVEL_WS_CLIENT=$(bashio::config 'log_level_websockets_client')
LOG_LEVEL_WS_SERVER=$(bashio::config 'log_level_websockets_server')
HOST_ADDR=$(bashio::config 'host_addr')
HOST_PORT=$(bashio::config 'host_port')
WATCHDOG_STALE=$(bashio::config 'watchdog_stale')
WATCHDOG_INTERVAL=$(bashio::config 'watchdog_interval')
PING_TIMEOUT=$(bashio::config 'ping_timeout')
PRIMARY_SERVER=$(bashio::config 'primary_server')
SECONDARY_SERVER=$(bashio::config 'secondary_server')

bashio::log.info "Starting OCPP 2-Way Proxy..."

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

bashio::log.info "Configuration:"
bashio::log.info "  Primary Server: ${PRIMARY_SERVER}"
if [ -n "${SECONDARY_SERVER}" ]; then
    bashio::log.info "  Secondary Server: ${SECONDARY_SERVER}"
else
    bashio::log.info "  Secondary Server: Not configured (1-way mode)"
fi
bashio::log.info "  Listening on: ${HOST_ADDR}:${HOST_PORT}"

# Start the application
exec python3 /app/ocpp-2w-proxy.py

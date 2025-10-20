# Home Assistant Add-on: OCPP 2-Way Proxy

## About

A 2-way OCPP proxy (can also be used as a 1-way simple proxy) that allows EV chargers to establish connections with two central management systems (CSMS) simultaneously.

This is useful when you want your charger to connect to an official server (e.g., for billing purposes) while also integrating it with Home Assistant for monitoring and control.

## How it works

The proxy works by defining a primary and a secondary server. This governs how the proxy forwards messages upstream and downstream:

1. **All Calls** (OCPP type 2) from the charger are forwarded to both the primary and secondary server
2. **All Replies/Errors** (OCPP type 3/4) from the **primary** server are forwarded to the charger
3. **All Replies/Errors** (OCPP type 3/4) from the **secondary** server are **ignored** and not forwarded to the charger
4. **All Calls** (OCPP type 2) from either server are forwarded to the charger, with the message_id tracked
5. **All Replies/Errors** (OCPP type 3/4) from the charger are forwarded to the correct server based on the tracked message_id

The proxy includes a watchdog that monitors connections and closes stale connections that haven't been active for the configured timeout period.

## Configuration

### Option: `log_level`

The log level for the proxy itself.

- **DEBUG**: Very detailed logging
- **INFO**: Standard logging (recommended)
- **WARNING**: Only warnings and errors
- **ERROR**: Only errors

### Option: `log_level_websockets_client`

The log level for the WebSocket client (connections to upstream servers).

### Option: `log_level_websockets_server`

The log level for the WebSocket server (connections from chargers).

### Option: `host_addr`

The IP address to listen on. Default is `0.0.0.0` (all interfaces).

### Option: `host_port`

The port to listen on for incoming charger connections. Default is `8321`.

### Option: `watchdog_stale`

Time in seconds after which an inactive connection is considered stale and will be closed. Default is `500`.

### Option: `watchdog_interval`

How often (in seconds) the watchdog checks for stale connections. Default is `100`.

### Option: `ping_timeout`

WebSocket ping timeout in seconds. Default is `60`.

### Option: `primary_server` (required)

The URL of your primary CSMS server. This is typically your official/production server.

Example: `ws://ocpp.example.com:80` or `wss://secure.example.com:443`

### Option: `secondary_server` (optional)

The URL of your secondary CSMS server. This is typically your Home Assistant OCPP integration.

Example: `ws://homeassistant.local:8888`

Leave empty if you only want to use the proxy in 1-way mode (simple proxy).

## Example Configuration

```yaml
log_level: INFO
log_level_websockets_client: INFO
log_level_websockets_server: INFO
host_addr: 0.0.0.0
host_port: 8321
watchdog_stale: 500
watchdog_interval: 100
ping_timeout: 60
primary_server: "ws://ocpp.provider.com:80"
secondary_server: "ws://192.168.1.100:8888"
```

## Usage

1. Install the add-on
2. Configure the primary server (your official CSMS)
3. Configure the secondary server (optional, e.g., Home Assistant OCPP integration)
4. Start the add-on
5. Point your EV charger to connect to `ws://<home-assistant-ip>:8321`

## Support

For issues and questions, please visit the [GitHub repository](https://github.com/yourusername/ocpp-2w-proxy).

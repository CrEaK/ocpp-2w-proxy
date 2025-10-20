ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install requirements for add-on
RUN \
  apk add --no-cache \
    python3 \
    py3-pip \
    jq \
    bash

# Set the working directory in the container
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Copy application files
COPY ocpp-2w-proxy.py .

# Setup s6-overlay service
RUN mkdir -p /etc/services.d/ocpp-proxy
COPY run.sh /etc/services.d/ocpp-proxy/run
RUN chmod a+x /etc/services.d/ocpp-proxy/run


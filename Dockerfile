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
COPY run.sh .

# Make run script executable
RUN chmod a+x run.sh

# Copy run.sh to the proper location for Home Assistant
COPY run.sh /

# Run the add-on
CMD ["/run.sh"]


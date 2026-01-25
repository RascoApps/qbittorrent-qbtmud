FROM ghcr.io/hotio/qbittorrent:latest

# Set metadata
LABEL maintainer="RascoApps"
LABEL description="qBittorrent with qbtmud custom WebUI"

# Install qbtmud custom UI during build
# Using specific version to ensure reproducible builds
ARG QBTMUD_VERSION=2.1.0
ARG QBTMUD_VERSION_ENCODED=2.1.0
RUN mkdir -p /app/defaults/webui && \
    cd /tmp && \
    echo "Downloading qbtmud version ${QBTMUD_VERSION}..." && \
    curl -L -o qbtmud.zip "https://github.com/lantean-code/qbtmud/releases/download/${QBTMUD_VERSION_ENCODED}/qbt-mud-v${QBTMUD_VERSION}.zip" && \
    unzip -q qbtmud.zip -d qbtmud_extracted && \
    # Install to defaults directory
    cp -r qbtmud_extracted/* /app/defaults/webui/ && \
    # Verify installation
    test -f /app/defaults/webui/public/index.html || exit 1 && \
    # Clean up
    rm -rf /tmp/qbtmud.zip /tmp/qbtmud_extracted && \
    echo "qbtmud custom WebUI v${QBTMUD_VERSION} installed to image"

# Copy configuration script and s6 service
COPY configure-qbtmud.sh /app/configure-qbtmud.sh
COPY root/ /

# Make it executable
RUN chmod +x /app/configure-qbtmud.sh /etc/s6-overlay/s6-rc.d/init-qbtmud/run

# Expose ports
# 8080 - WebUI
# 6881 - Torrent port (TCP)
# 6881 - Torrent port (UDP)
EXPOSE 8080 6881 6881/udp

# Volume for configuration and data
VOLUME ["/config", "/data"]

FROM lscr.io/linuxserver/qbittorrent:latest

# Set metadata
LABEL maintainer="RascoApps"
LABEL description="qBittorrent with qbtmud custom WebUI"

# Install qbtmud custom UI during build
# Using specific version to ensure reproducible builds
ARG QBTMUD_VERSION=2.1.0-rc.1+15
ARG QBTMUD_VERSION_ENCODED=2.1.0-rc.1%2B15
RUN mkdir -p /defaults/webui && \
    cd /tmp && \
    echo "Downloading qbtmud version ${QBTMUD_VERSION}..." && \
    curl -kL -o qbtmud.zip "https://github.com/lantean-code/qbtmud/releases/download/${QBTMUD_VERSION_ENCODED}/qbt-mud-v${QBTMUD_VERSION_ENCODED}.zip" && \
    unzip -q qbtmud.zip -d qbtmud_extracted && \
    # Install to defaults directory (LinuxServer.io copies this to /config on first run)
    cp -r qbtmud_extracted/* /defaults/webui/ && \
    # Verify installation
    test -f /defaults/webui/public/index.html || exit 1 && \
    # Clean up
    rm -rf /tmp/qbtmud.zip /tmp/qbtmud_extracted && \
    echo "qbtmud custom WebUI v${QBTMUD_VERSION} installed to image"

# Copy the configuration script
COPY configure-qbtmud.sh /custom-cont-init.d/configure-qbtmud.sh

# Make it executable
RUN chmod +x /custom-cont-init.d/configure-qbtmud.sh

# Set default environment variables for LAN auth bypass
ENV BYPASS_LOCAL_AUTH=true
ENV AUTH_SUBNETS="192.168.0.0/24"

# Expose ports
# 8080 - WebUI
# 6881 - Torrent port (TCP)
# 6881 - Torrent port (UDP)
EXPOSE 8080 6881 6881/udp

# Volume for configuration and downloads
VOLUME ["/config", "/downloads"]

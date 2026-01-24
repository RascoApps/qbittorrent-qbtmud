FROM lscr.io/linuxserver/qbittorrent:latest

# Set metadata
LABEL maintainer="RascoApps"
LABEL description="qBittorrent with qbtmud custom WebUI"

# Create custom-cont-init.d directory if it doesn't exist
RUN mkdir -p /custom-cont-init.d

# Copy the startup script
COPY install-qbtmud.sh /custom-cont-init.d/install-qbtmud.sh

# Make it executable
RUN chmod +x /custom-cont-init.d/install-qbtmud.sh

# Expose ports
# 8080 - WebUI
# 6881 - Torrent port (TCP)
# 6881 - Torrent port (UDP)
EXPOSE 8080 6881 6881/udp

# Volume for configuration and downloads
VOLUME ["/config", "/downloads"]

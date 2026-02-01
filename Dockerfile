FROM lscr.io/linuxserver/qbittorrent:latest

# Set metadata
LABEL maintainer="RascoApps"
LABEL description="qBittorrent with qbtmud custom WebUI"

# Install qbtmud custom UI during build
# Always pull the latest release unless overridden
ARG QBTMUD_VERSION=latest
ARG QBTMUD_RELEASES_URL=https://github.com/lantean-code/qbtmud/releases/latest
ARG QBTMUD_ZIP_URL=latest
ARG QBTMUD_SHA256=skip
RUN set -eu && \
    mkdir -p /defaults/webui && \
    cd /tmp && \
    QBTMUD_VERSION_TAG="${QBTMUD_VERSION}" && \
    if [ "${QBTMUD_VERSION}" = "latest" ]; then \
        QBTMUD_RELEASE_HEADERS=$(curl -fsSLI --max-time 30 "${QBTMUD_RELEASES_URL}") || { \
            echo "Failed to fetch latest qbtmud release headers from ${QBTMUD_RELEASES_URL}" >&2; \
            exit 1; \
        }; \
        QBTMUD_RELEASE_LOCATION=$(printf '%s' "${QBTMUD_RELEASE_HEADERS}" | \
            grep -i '^location:' | head -n 1); \
        if [ -z "${QBTMUD_RELEASE_LOCATION}" ]; then \
            echo "No release location header found from ${QBTMUD_RELEASES_URL}" >&2; \
            exit 1; \
        fi; \
        QBTMUD_VERSION_TAG=$(printf '%s' "${QBTMUD_RELEASE_LOCATION}" | sed 's|.*/tag/||' | tr -d '\r'); \
    fi && \
    if [ -z "${QBTMUD_VERSION_TAG}" ]; then \
        echo "Resolved an empty qbtmud release tag from ${QBTMUD_RELEASES_URL}" >&2; \
        exit 1; \
    fi && \
    case "${QBTMUD_VERSION_TAG}" in \
        v*) QBTMUD_VERSION="${QBTMUD_VERSION_TAG#v}" ;; \
        *) QBTMUD_VERSION="${QBTMUD_VERSION_TAG}" ;; \
    esac && \
    QBTMUD_VERSION_ENCODED=$(printf '%s' "${QBTMUD_VERSION}" | sed 's/+/%2B/g') && \
    if [ "${QBTMUD_ZIP_URL}" = "latest" ]; then \
        QBTMUD_ZIP_URL="https://github.com/lantean-code/qbtmud/releases/download/${QBTMUD_VERSION_ENCODED}/qbt-mud-v${QBTMUD_VERSION_ENCODED}.zip"; \
    fi && \
    echo "Downloading qbtmud version ${QBTMUD_VERSION}..." && \
    curl -fsSL -o qbtmud.zip "${QBTMUD_ZIP_URL}" && \
    if [ "${QBTMUD_SHA256}" != "skip" ]; then \
        echo "${QBTMUD_SHA256}  qbtmud.zip" | sha256sum -c -; \
    fi && \
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

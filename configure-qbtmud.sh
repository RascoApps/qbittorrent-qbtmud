#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Configure qBittorrent to use qbtmud custom UI
WEBUI_DIR="/config/qBittorrent/webui"

# Copy qbtmud from defaults if not already present
if [ ! -f "${WEBUI_DIR}/public/index.html" ]; then
    echo "Copying qbtmud WebUI to config directory..."
    mkdir -p "${WEBUI_DIR}"
    cp -r /defaults/webui/* "${WEBUI_DIR}/"
    echo "qbtmud custom WebUI copied successfully!"
fi

# Enable alternative WebUI in qBittorrent config
CONFIG_FILE="/config/qBittorrent/qBittorrent.conf"
if [ -f "$CONFIG_FILE" ]; then
    echo "Configuring qBittorrent to use qbtmud WebUI..."
    # Check if WebUI section exists
    if grep -q "\[Preferences\]" "$CONFIG_FILE"; then
        # Add or update the WebUI settings
        if grep -q "WebUI\\\\AlternativeUIEnabled" "$CONFIG_FILE"; then
            sed -i 's/WebUI\\AlternativeUIEnabled=.*/WebUI\\AlternativeUIEnabled=true/' "$CONFIG_FILE"
        else
            sed -i '/\[Preferences\]/a WebUI\\AlternativeUIEnabled=true' "$CONFIG_FILE"
        fi
        
        if grep -q "WebUI\\\\RootFolder" "$CONFIG_FILE"; then
            sed -i "s|WebUI\\\\RootFolder=.*|WebUI\\\\RootFolder=${WEBUI_DIR}|" "$CONFIG_FILE"
        else
            sed -i "/\[Preferences\]/a WebUI\\\\RootFolder=${WEBUI_DIR}" "$CONFIG_FILE"
        fi
        
        echo "qBittorrent configured to use qbtmud WebUI"
    fi
fi

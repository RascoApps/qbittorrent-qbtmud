#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Install qbtmud custom UI if not already installed
WEBUI_DIR="/config/qBittorrent/webui"
MARKER_FILE="${WEBUI_DIR}/.qbtmud-installed"

if [ ! -f "$MARKER_FILE" ]; then
    echo "Installing qbtmud custom WebUI..."
    
    # Create webui directory
    mkdir -p "${WEBUI_DIR}"
    
    # Download the latest release
    QBTMUD_URL=$(curl -s https://api.github.com/repos/lantean-code/qbtmud/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4)
    
    if [ -z "$QBTMUD_URL" ]; then
        echo "ERROR: Could not find qbtmud download URL"
        exit 1
    fi
    
    echo "Downloading qbtmud from: $QBTMUD_URL"
    
    # Download and extract
    cd /tmp || exit 1
    curl -L -o qbtmud.zip "$QBTMUD_URL"
    unzip -q qbtmud.zip -d qbtmud_extracted
    
    # Move files to webui directory
    mv qbtmud_extracted/* "${WEBUI_DIR}/" 2>/dev/null || true
    
    # Clean up
    rm -rf qbtmud.zip qbtmud_extracted
    
    # Create marker file
    touch "$MARKER_FILE"
    
    echo "qbtmud custom WebUI installed successfully!"
    
    # Enable alternative WebUI in qBittorrent config
    CONFIG_FILE="/config/qBittorrent/qBittorrent.conf"
    if [ -f "$CONFIG_FILE" ]; then
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
else
    echo "qbtmud custom WebUI already installed, skipping..."
fi

#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Configure qBittorrent to use qbtmud custom UI
WEBUI_DIR="/config/qBittorrent/webui"

# Set defaults for LAN auth bypass
BYPASS_LOCAL_AUTH="${BYPASS_LOCAL_AUTH:-true}"
AUTH_SUBNETS="${AUTH_SUBNETS:-192.168.0.0/24}"

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

# Configure LAN auth bypass if enabled
if [ "$BYPASS_LOCAL_AUTH" = "true" ]; then
    echo "Configuring LAN auth bypass..."
    
    if [ -f "$CONFIG_FILE" ] && grep -q "\[Preferences\]" "$CONFIG_FILE"; then
        # Set BypassLocalAuth=true
        if grep -q "WebUI\\\\BypassLocalAuth" "$CONFIG_FILE"; then
            sed -i 's/WebUI\\BypassLocalAuth=.*/WebUI\\BypassLocalAuth=true/' "$CONFIG_FILE"
        else
            sed -i '/\[Preferences\]/a WebUI\\BypassLocalAuth=true' "$CONFIG_FILE"
        fi
        
        # Set AuthSubnetWhitelistEnabled=true
        if grep -q "WebUI\\\\AuthSubnetWhitelistEnabled" "$CONFIG_FILE"; then
            sed -i 's/WebUI\\AuthSubnetWhitelistEnabled=.*/WebUI\\AuthSubnetWhitelistEnabled=true/' "$CONFIG_FILE"
        else
            sed -i '/\[Preferences\]/a WebUI\\AuthSubnetWhitelistEnabled=true' "$CONFIG_FILE"
        fi
        
        # Add/merge AUTH_SUBNETS into AuthSubnetWhitelist
        if grep -q "WebUI\\\\AuthSubnetWhitelist=" "$CONFIG_FILE"; then
            # Get existing whitelist
            EXISTING_SUBNETS=$(grep "WebUI\\\\AuthSubnetWhitelist=" "$CONFIG_FILE" | sed 's/.*WebUI\\AuthSubnetWhitelist=//')
            
            # Merge subnets, avoiding duplicates
            IFS=',' read -ra NEW_SUBNETS <<< "$AUTH_SUBNETS"
            
            # Build merged list
            MERGED_SUBNETS="$EXISTING_SUBNETS"
            for subnet in "${NEW_SUBNETS[@]}"; do
                subnet=$(echo "$subnet" | xargs) # trim whitespace
                if [ -n "$subnet" ]; then
                    # Check if subnet already exists (exact match with word boundaries)
                    if ! echo ",$EXISTING_SUBNETS," | grep -q ",$subnet,"; then
                        if [ -n "$MERGED_SUBNETS" ]; then
                            MERGED_SUBNETS="${MERGED_SUBNETS}, ${subnet}"
                        else
                            MERGED_SUBNETS="$subnet"
                        fi
                    fi
                fi
            done
            
            # Update the config with merged list
            sed -i "s|WebUI\\\\AuthSubnetWhitelist=.*|WebUI\\\\AuthSubnetWhitelist=${MERGED_SUBNETS}|" "$CONFIG_FILE"
            echo "LAN auth bypass configured with merged subnets: ${MERGED_SUBNETS}"
        else
            # Add new AuthSubnetWhitelist entry
            sed -i "/\[Preferences\]/a WebUI\\\\AuthSubnetWhitelist=${AUTH_SUBNETS}" "$CONFIG_FILE"
            echo "LAN auth bypass configured with subnets: ${AUTH_SUBNETS}"
        fi
    fi
fi

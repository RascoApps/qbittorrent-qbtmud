# qBittorrent with qbtmud Custom WebUI

A Docker solution that combines the latest qBittorrent release with the modern [qbtmud](https://github.com/lantean-code/qbtmud) custom WebUI, pre-installed during the image build.

## Features

- **Latest qBittorrent**: Based on LinuxServer.io's qBittorrent image (v5.1.4+)
- **qbtmud WebUI**: Modern, user-friendly custom interface (v2.2.0-rc.2+5) pre-installed in the image
- **Easy Deployment**: Simple Docker Compose setup or direct docker run
- **Persistent Storage**: Configuration and downloads are preserved
- **Cross-Platform**: Works on x86-64, ARM64, and other architectures
- **Fast Startup**: WebUI is bundled in the image, no download needed at container startup
- **Published Package**: Available on GitHub Container Registry

## Quick Start

### Option 1: Using Pre-built Image (Recommended)

Use the published container image from GitHub Container Registry:

```bash
docker run -d \
  --name=qbittorrent-qbtmud \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e WEBUI_PORT=8080 \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v ./config:/config \
  -v ./downloads:/downloads \
  --restart unless-stopped \
  ghcr.io/rascoapps/qbittorrent-qbtmud:latest
```

Or with Docker Compose:

```yaml
services:
  qbittorrent:
    image: ghcr.io/rascoapps/qbittorrent-qbtmud:latest
    container_name: qbittorrent-qbtmud
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - WEBUI_PORT=8080
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
    restart: unless-stopped
```

### Option 2: Building from Source

### Prerequisites

- Docker
- Docker Compose

### Installation

1. Clone this repository:
```bash
git clone https://github.com/RascoApps/qbittorrent-qbtmud.git
cd qbittorrent-qbtmud
```

2. Start the container:
```bash
docker-compose up -d
```

3. Access the WebUI:
- Open your browser and navigate to `http://localhost:8080`
- Default credentials:
  - Username: `admin`
  - Password: `adminadmin`

**Important**: Change the default password immediately after first login!

### Configuration

#### Environment Variables

You can customize the following environment variables in `docker-compose.yml`:

- `PUID=1000` - User ID for file permissions
- `PGID=1000` - Group ID for file permissions
- `TZ=Etc/UTC` - Timezone (e.g., `America/New_York`, `Europe/London`)
- `WEBUI_PORT=8080` - WebUI port
- `BYPASS_LOCAL_AUTH=true` - Bypass authentication for local network clients (default: `true`)
- `AUTH_SUBNETS=192.168.0.0/24` - Comma-separated list of IP subnets to whitelist for auth bypass (default: `192.168.0.0/24`)

#### Volumes

- `./config:/config` - qBittorrent configuration files
- `./downloads:/downloads` - Default download directory

#### Ports

- `8080` - WebUI access port
- `6881` - Torrent traffic port (TCP)
- `6881` - Torrent traffic port (UDP)

### Building from Source

If you want to build the Docker image yourself:

```bash
docker build -t qbittorrent-qbtmud .
```

## Usage

### Starting the Container

```bash
docker-compose up -d
```

### Stopping the Container

```bash
docker-compose down
```

### Viewing Logs

```bash
docker-compose logs -f
```

### Updating

To update to the latest version:

```bash
docker-compose pull
docker-compose up -d
```

### Automation

This repository includes a scheduled workflow that checks for new qBittorrent and qbtmud releases daily. When a new release is detected, the workflow updates `.github/upstream-versions.json`, commits the change, and triggers the Docker image rebuild. CI runs shellcheck on the startup script and validates the Docker build on pushes and pull requests (pinned to a known qbtmud release).

## About qbtmud

[qbtmud](https://github.com/lantean-code/qbtmud) is a drop-in replacement WebUI for qBittorrent that provides:

- Modern and intuitive interface
- Full feature parity with the default WebUI
- Tracker and peer management
- File prioritization
- Global and per-torrent speed limits
- RSS integration and search functionality
- Sequential downloading and super seeding
- And much more!

## Troubleshooting

### Cannot Access WebUI

1. Ensure the container is running: `docker-compose ps`
2. Check the logs: `docker-compose logs`
3. Verify port 8080 is not used by another application
4. Try accessing via `http://127.0.0.1:8080` or your server's IP

### Permission Issues

If you encounter permission issues with downloads:

1. Check your PUID and PGID settings
2. Ensure the user has write permissions to the downloads directory
3. On Linux, you can find your user ID with: `id -u` and group ID with: `id -g`

### Reset Password

If you forget your password:

1. Stop the container: `docker-compose down`
2. Delete the config file: `rm -rf config/qBittorrent/qBittorrent.conf`
3. Restart the container: `docker-compose up -d`
4. Use default credentials and set a new password

## License

This project combines:
- qBittorrent (GPL-2.0 License)
- qbtmud (GPL-3.0 License)
- LinuxServer.io Docker image

## Credits

- [qBittorrent](https://www.qbittorrent.org/) - The qBittorrent project
- [qbtmud](https://github.com/lantean-code/qbtmud) - The custom WebUI
- [LinuxServer.io](https://www.linuxserver.io/) - Docker image base

## Support

For issues related to:
- **Docker setup**: Open an issue in this repository
- **qBittorrent**: Visit the [qBittorrent GitHub](https://github.com/qbittorrent/qBittorrent)
- **qbtmud UI**: Visit the [qbtmud GitHub](https://github.com/lantean-code/qbtmud)

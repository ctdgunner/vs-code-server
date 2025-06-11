# VS Code Server with Development Tools

A Docker container providing VS Code Server with web interface access and SSH connectivity. Provides a full Visual Studio Code development environment accessible through your browser or acts as a host for Remote-SSH from any desktop VS Code environment. This container is preloaded with development tools.

## Features

- **VS Code Server** - Browser-based VS Code interface accessible at http://[IP]:8000/
- **SSH Access** - Secure remote terminal access via SSH keys (port 2222)
- **Development Tools** - Python, Node.js, npm, Git, and Claude Code pre-installed
- **Persistent Storage** - VS Code settings and workspace data persist across restarts
- **Git Integration** - Configurable git user name and email via environment variables

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url>
   cd vs-code-server
   ```

2. **Create required directories:**
   ```bash
   mkdir -p workspace config ssh
   ```

3. **Add your SSH public key:**
   ```bash
   cp ~/.ssh/id_rsa.pub ssh/authorized_keys
   # Or generate a new key if needed:
   # ssh-keygen -t rsa -b 4096 -f ssh/vscode_server_key
   # cp ssh/vscode_server_key.pub ssh/authorized_keys
   ```

4. **Start with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

5. **Access your development environment:**
   - **VS Code**: http://localhost:8000
   - **SSH**: `ssh -i ssh/vscode_server_key root@localhost -p 2222`

## Docker Compose Configuration

Use the provided `docker-compose.yml` file for easy setup:

```yaml
version: '3.8'

services:
  vs-code-server:
    build: .
    # Or use pre-built image: ctdgunner/vs-code-server:latest
    ports:
      - "8000:8000"  # VS Code Server web interface
      - "2222:22"    # SSH access
    volumes:
      # Projects Directory
      - ./workspace:/root/workspace
      
      # VS Code App Data
      - ./config:/root/.vscode/
      
      # SSH Keys
      - ./ssh:/root/.ssh/:ro
    environment:
      - SHELL=/bin/bash
      - TZ=UTC
      - GIT_USER_NAME=
      - GIT_USER_EMAIL=
    restart: unless-stopped
    container_name: vs-code-server
    hostname: vscode
```

## Manual Docker Run

If you prefer using `docker run` directly:

```bash
docker run -d \
  --name vs-code-server \
  --hostname vscode \
  -p 8000:8000 \
  -p 2222:22 \
  -v $(pwd)/workspace:/root/workspace \
  -v $(pwd)/config:/root/.vscode/ \
  -v $(pwd)/ssh:/root/.ssh/:ro \
  -e SHELL=/bin/bash \
  -e TZ=UTC \
  -e GIT_USER_NAME= \
  -e GIT_USER_EMAIL= \
  --restart unless-stopped \
  ctdgunner/vs-code-server:latest
```

## Directory Structure

```
vs-code-server/
├── Dockerfile
├── entrypoint.sh
├── docker-compose.yml
├── README.md
├── unraid_template.xml
├── .github/workflows/docker-build.yml
├── workspace/            # Your development projects and workspace
├── config/               # VS Code app data and configuration
└── ssh/                  # SSH keys for access
    └── authorized_keys   # Your public SSH key
```

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 8000 | VS Code Server | Browser-based VS Code interface |
| 22/2222 | SSH | Secure shell access (mapped to host port 2222) |

## Volume Mounts

### Required
- `./workspace:/root/workspace` - Your development projects and workspace
- `./config:/root/.vscode/` - VS Code app data, settings, extensions, and configuration
- `./ssh:/root/.ssh/:ro` - SSH authorized keys for secure access

## Pre-installed Tools

- **Git** - Version control
- **Python 3** - With pip and venv
- **Node.js & npm** - JavaScript runtime and package manager
- **Claude Code** - Anthropic's AI coding assistant
- **VS Code Server** - Browser-based development environment
- **SSH Server** - Secure remote access

## SSH Configuration

The container uses key-based SSH authentication for security:

1. **Generate SSH keys** (if you don't have them):
   ```bash
   ssh-keygen -t rsa -b 4096 -f ssh/vscode_server_key
   ```

2. **Copy public key to authorized_keys**:
   ```bash
   cp ssh/vscode_server_key.pub ssh/authorized_keys
   ```

3. **Connect via SSH**:
   ```bash
   ssh -i ssh/vscode_server_key root@localhost -p 2222
   ```

## VS Code Server Access

1. Open your browser to http://localhost:8000
2. Your VS Code interface will load with all extensions and settings preserved
3. Use the integrated terminal or connect via SSH for command-line access

## Development Workflow

1. **Start the container**: `docker-compose up -d`
2. **Access VS Code**: Open http://localhost:8000 in your browser
3. **SSH access**: Use `ssh -i ssh/vscode_server_key root@localhost -p 2222`
4. **Install extensions**: Extensions persist in the `./config` volume
5. **Develop**: Your projects in `./workspace` are available at `/root/workspace`

## GitHub Actions

The repository includes automatic Docker image building:

- **Triggers**: Pushes to main/master, PRs, daily base image checks
- **Registry**: Docker Hub (docker.io)
- **Base image monitoring**: Automatically rebuilds when `ahmadnassri/vscode-server:latest` updates

To use the pre-built image, update your `docker-compose.yml`:
```yaml
services:
  vs-code-server:
    image: ctdgunner/vs-code-server:latest
    # Remove the 'build: .' line
```

## Troubleshooting

### SSH Connection Issues
- Ensure your public key is in `ssh/authorized_keys`
- Check file permissions: `chmod 600 ssh/authorized_keys`
- Verify the container is running: `docker-compose ps`

### VS Code Server Issues
- Check logs: `docker-compose logs vs-code-server`
- Ensure port 8000 is not blocked by firewall
- Clear browser cache if the interface doesn't load

### Permission Issues
- Ensure proper ownership of mounted volumes
- Run with proper user mapping if needed

## Customization

### Adding More Tools
Edit the `Dockerfile` to install additional packages:
```dockerfile
RUN apt-get update && apt-get install -y your-package
```

### Changing Ports
Update the `docker-compose.yml` port mappings:
```yaml
ports:
  - "9000:8000"  # Change VS Code port
  - "2223:22"    # Change SSH port
```

### Environment Variables
Add environment variables in `docker-compose.yml`:
```yaml
environment:
  - SHELL=/bin/bash
  - TZ=UTC  # Set your timezone
  - GIT_USER_NAME=Your Name  # Set git user name
  - GIT_USER_EMAIL=your.email@example.com  # Set git user email
```

## Security Notes

- SSH uses key-based authentication only (passwords disabled)
- Container runs as root (suitable for development environments)
- For production use, consider running as non-root user
- Keep your SSH private keys secure and never commit them to version control

## License

This project extends [ahmadnassri/vscode-server](https://github.com/ahmadnassri/docker-vscode-server) with additional development tools and SSH access.

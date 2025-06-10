# VS Code Server with Development Tools

A Docker container based on `ahmadnassri/vscode-server:latest` with additional development tools and SSH access for remote development.

## Features

- **VS Code Server** - Browser-based VS Code interface
- **SSH Access** - Secure remote terminal access via SSH keys
- **Development Tools** - Python, Node.js, npm, Git, and Claude Code pre-installed
- **Persistent Storage** - VS Code settings and extensions persist across restarts
- **Dual Service** - Both VS Code server and SSH daemon run simultaneously

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url>
   cd vs-code-server
   ```

2. **Create required directories:**
   ```bash
   mkdir -p server-data user-data cli-data extensions ssh-keys
   ```

3. **Add your SSH public key:**
   ```bash
   cp ~/.ssh/id_rsa.pub ssh-keys/authorized_keys
   # Or generate a new key if needed:
   # ssh-keygen -t rsa -b 4096 -f ssh-keys/vscode_server_key
   # cp ssh-keys/vscode_server_key.pub ssh-keys/authorized_keys
   ```

4. **Start with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

5. **Access your development environment:**
   - **VS Code**: http://localhost:8000
   - **SSH**: `ssh -i ssh-keys/vscode_server_key root@localhost -p 2222`

## Docker Compose Configuration

Use the provided `docker-compose.yml` file for easy setup:

```yaml
version: '3.8'

services:
  vscode-server:
    build: .
    # Or use pre-built image: ghcr.io/your-username/your-repo:latest
    ports:
      - "8000:8000"  # VS Code Server
      - "2222:22"    # SSH Access
    volumes:
      # VS Code data persistence (from original container)
      - ./server-data:/root/.vscode/server-data
      - ./user-data:/root/.vscode/user-data
      - ./cli-data:/root/.vscode/cli-data
      - ./extensions:/root/.vscode/extensions
      
      # SSH key for secure access
      - ./ssh-keys/authorized_keys:/root/.ssh/authorized_keys:ro
      
      # Optional: Mount your projects
      - ./projects:/workspace
      
      # Optional: Mount additional config
      - ./config:/root/.config
    environment:
      - SHELL=/bin/bash
    restart: unless-stopped
    container_name: vscode-dev-server
```

## Manual Docker Run

If you prefer using `docker run` directly:

```bash
docker run -d \
  --name vscode-dev-server \
  -p 8000:8000 \
  -p 2222:22 \
  -v $(pwd)/server-data:/root/.vscode/server-data \
  -v $(pwd)/user-data:/root/.vscode/user-data \
  -v $(pwd)/cli-data:/root/.vscode/cli-data \
  -v $(pwd)/extensions:/root/.vscode/extensions \
  -v $(pwd)/ssh-keys/authorized_keys:/root/.ssh/authorized_keys:ro \
  -v $(pwd)/projects:/workspace \
  --restart unless-stopped \
  ghcr.io/your-username/your-repo:latest
```

## Directory Structure

```
vs-code-server/
├── Dockerfile
├── docker-compose.yml
├── README.md
├── .github/workflows/docker-build.yml
├── server-data/          # VS Code server data
├── user-data/            # VS Code user settings
├── cli-data/             # VS Code CLI data
├── extensions/           # VS Code extensions
├── ssh-keys/             # SSH keys for access
│   └── authorized_keys   # Your public SSH key
├── projects/             # Your development projects (optional)
└── config/               # Additional config files (optional)
```

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 8000 | VS Code Server | Browser-based VS Code interface |
| 22/2222 | SSH | Secure shell access (mapped to host port 2222) |

## Volume Mounts

### Required (from original container)
- `./server-data:/root/.vscode/server-data` - VS Code server configuration
- `./user-data:/root/.vscode/user-data` - User settings and preferences
- `./cli-data:/root/.vscode/cli-data` - CLI data and cache
- `./extensions:/root/.vscode/extensions` - Installed extensions

### Added for SSH Access
- `./ssh-keys/authorized_keys:/root/.ssh/authorized_keys:ro` - SSH public keys

### Optional
- `./projects:/workspace` - Your development projects
- `./config:/root/.config` - Additional configuration files

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
   ssh-keygen -t rsa -b 4096 -f ssh-keys/vscode_server_key
   ```

2. **Copy public key to authorized_keys**:
   ```bash
   cp ssh-keys/vscode_server_key.pub ssh-keys/authorized_keys
   ```

3. **Connect via SSH**:
   ```bash
   ssh -i ssh-keys/vscode_server_key root@localhost -p 2222
   ```

## VS Code Server Access

1. Open your browser to http://localhost:8000
2. Your VS Code interface will load with all extensions and settings preserved
3. Use the integrated terminal or connect via SSH for command-line access

## Development Workflow

1. **Start the container**: `docker-compose up -d`
2. **Access VS Code**: Open http://localhost:8000 in your browser
3. **SSH access**: Use `ssh -i ssh-keys/vscode_server_key root@localhost -p 2222`
4. **Install extensions**: Extensions persist in the `./extensions` volume
5. **Develop**: Your projects in `./projects` are available at `/workspace`

## GitHub Actions

The repository includes automatic Docker image building:

- **Triggers**: Pushes to main/master, PRs, daily base image checks
- **Registry**: Docker Hub (docker.io)
- **Base image monitoring**: Automatically rebuilds when `ahmadnassri/vscode-server:latest` updates

To use the pre-built image, update your `docker-compose.yml`:
```yaml
services:
  vscode-server:
    image: ctdgunner/vs-code-server:latest
    # Remove the 'build: .' line
```

## Troubleshooting

### SSH Connection Issues
- Ensure your public key is in `ssh-keys/authorized_keys`
- Check file permissions: `chmod 600 ssh-keys/authorized_keys`
- Verify the container is running: `docker-compose ps`

### VS Code Server Issues
- Check logs: `docker-compose logs vscode-server`
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
  - YOUR_ENV_VAR=value
```

## Security Notes

- SSH uses key-based authentication only (passwords disabled)
- Container runs as root (suitable for development environments)
- For production use, consider running as non-root user
- Keep your SSH private keys secure and never commit them to version control

## License

This project extends [ahmadnassri/vscode-server](https://github.com/ahmadnassri/docker-vscode-server) with additional development tools and SSH access.

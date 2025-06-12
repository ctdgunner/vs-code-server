# VS Code Server with Development Tools

A Docker container providing VS Code Server with web interface access and SSH connectivity. Provides a full Visual Studio Code development environment accessible through your browser or acts as a host for Remote-SSH from any desktop VS Code environment. This container is preloaded with development tools.

## Features

- **VS Code Server** - Browser-based VS Code interface accessible at http://[IP]:8000/
- **SSH Access** - Secure remote terminal access via SSH password (port 2222)
- **Development Tools** - Python, Node.js, npm, Git, and **Claude Code** pre-installed
- **Persistent Storage** - VS Code settings, third party configs, and projects data persist across restarts
- **Git Integration** - Configurable git user name and email via environment variables

## Quick Start

### Option 1: Docker Compose

Use the provided `docker-compose.yml` file for easy setup:

```yaml
version: '3.8'

services:
  vs-code-server:
    image: ctdgunner/vs-code-server:latest
    
    ports:
      - "8000:8000"  # VS Code Server web interface
      - "2222:22"    # SSH access (mapped to avoid conflicts with host SSH)
    
    volumes:
      # Projects Directory
      - ./projects/:/projects/
      
      # VS Code App Data  
      - ./vs-code-server/:/root/
    
    environment:
      # Set default shell
      - SHELL=/bin/bash
      
      # Timezone
      - TZ=UTC
      
      # Git configuration via environment variables
      - GIT_USER_NAME=
      - GIT_USER_EMAIL=
    
    restart: unless-stopped
    
    container_name: vs-code-server
    
    # Add hostname for easier identification
    hostname: vscode
```

### Option 2: Manual Docker Run

If you prefer using `docker run` directly:

```bash
docker run -d \
  --name vs-code-server \
  --hostname vscode \
  -p 8000:8000 \
  -p 2222:22 \
  -v $(pwd)/projects:/projects \
  -v $(pwd)/vs-code-server:/root \
  -e SHELL=/bin/bash \
  -e TZ=UTC \
  -e SSH_PASSWORD=password \
  -e GIT_USER_NAME= \
  -e GIT_USER_EMAIL= \
  --restart unless-stopped \
  ctdgunner/vs-code-server:latest
```

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 8000 | VS Code Server | Browser-based VS Code interface |
| 22/2222 | SSH | Secure shell access (mapped to host port 2222) |

## Volume Mounts

### Required
- `./projects/:/projects/` - Your development projects and workspace
- `./vs-code-server/:/root/` - VS Code app data, settings, extensions, and configuration

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SHELL` | `/bin/bash` | Default shell environment |
| `TZ` | `UTC` | Container timezone |
| `SSH_PASSWORD` | `password` | SSH root password |
| `GIT_USER_NAME` | ` ` | Git user name for commits (optional) |
| `GIT_USER_EMAIL` | ` ` | Git user email for commits (optional) |

## Pre-installed Tools

- **Git** - Version control
- **Python 3** - With pip and venv
- **Node.js & npm** - JavaScript runtime and package manager
- **Claude Code** - Anthropic's AI coding assistant
- **VS Code Server** - Browser-based development environment
- **SSH Server** - Secure remote access

## SSH Configuration

The container uses password-based SSH authentication:

1. **Credentials**:
   - Username: `root`
   - Password: Set via `SSH_PASSWORD` environment variable (defaults to `password`)

2. **Connect via SSH**:
   ```bash
   ssh root@[IP] -p 2222
   ```

**Suggested SSH Config Template**
  ```
  Host vs-code-server-RAVEN
    HostName 192.168.50.155
    User root
    Port 2222
  ```

## VS Code Server Access

1. Open your browser to http://[IP]:8000
2. Your VS Code interface will load with all extensions and settings preserved
3. Use the integrated terminal or connect via SSH for command-line access

## Development Workflow

1. **Start the container**: `docker-compose up -d`
2. **Access VS Code**: Open http://[IP]:8000 in your browser
3. **SSH access**: Use `ssh root@[IP] -p 2222` with your configured password
4. **Install extensions**: Extensions persist in the `./vs-code-server` volume
5. **Develop**: Your projects in `./projects` are available at `/projects`

## GitHub Actions

The repository includes automatic Docker image building:

- **Triggers**: Pushes to main/master, PRs, daily base image checks
- **Registry**: Docker Hub (docker.io)
- **Base image monitoring**: Automatically rebuilds when `ahmadnassri/vscode-server:latest` updates

The pre-built image is used by default in the provided `docker-compose.yml`.

## Troubleshooting

### SSH Connection Issues
- Verify the container is running: `docker-compose ps`
- Ensure port 2222 is not blocked by firewall
- Check your SSH_PASSWORD environment variable is set correctly

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
  - SSH_PASSWORD=your_secure_password  # Set SSH password
  - GIT_USER_NAME=Your Name  # Set git user name
  - GIT_USER_EMAIL=your.email@example.com  # Set git user email
```

## Security Notes

- SSH uses password authentication configured via `SSH_PASSWORD` environment variable
- Container runs as root (suitable for development environments)
- For production use, consider running as non-root user and using key-based authentication

## License

This project extends [ahmadnassri/vscode-server](https://github.com/ahmadnassri/docker-vscode-server) with additional development tools and SSH access.

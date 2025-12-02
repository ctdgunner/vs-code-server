FROM ahmadnassri/vscode-server:latest

# Install development tools, SSH server, and gosu for privilege dropping
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    unzip \
    docker.io \
    docker-compose \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    make \
    gosu \
    sudo \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Setup SSH with password authentication (allow non-root users)
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'AllowUsers vscode' >> /etc/ssh/sshd_config

# Create vscode user with default UID/GID (will be overridden by PUID/PGID at runtime)
# Default to 99:100 (Unraid nobody:users)
RUN groupadd -g 100 vscode || groupmod -g 100 users && \
    useradd -u 99 -g 100 -m -s /bin/bash vscode || usermod -u 99 -g 100 vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG docker vscode || true

# Create necessary directories with proper permissions
RUN mkdir -p /home/vscode/.vscode-server && \
    mkdir -p /projects && \
    chown -R 99:100 /home/vscode && \
    chmod 755 /home/vscode

# Copy and setup entrypoint script for git configuration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add /projects shortcut to vscode home for ease of use within the container
RUN ln -s /projects /home/vscode/projects

# Expose ports for VS Code server and SSH
EXPOSE 8000 22

# Use our combined entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

FROM ahmadnassri/vscode-server:latest

# Install development tools and SSH server (removing duplicates already in base image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Setup SSH with password authentication
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Copy and setup entrypoint script for git configuration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports for VS Code server and SSH
EXPOSE 8000 22

# Use our combined entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

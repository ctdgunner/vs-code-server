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

# Setup SSH with key-based authentication
RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Copy and setup entrypoint script for git configuration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports for VS Code server and SSH
EXPOSE 8000 22

# Use our combined entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

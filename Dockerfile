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
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Copy and setup entrypoint script for git configuration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create startup script to run both services
RUN echo '#!/bin/bash\n\
# Start SSH daemon in background\n\
/usr/sbin/sshd -D &\n\
\n\
# Start VS Code server in foreground\n\
exec code serve-web --without-connection-token --accept-server-license-terms --host 0.0.0.0 --port 8000 --cli-data-dir /root/.vscode/cli-data --user-data-dir /root/.vscode/user-data --server-data-dir /root/.vscode/server-data --extensions-dir /root/.vscode/extensions' > /start.sh && \
    chmod +x /start.sh

# Expose ports for VS Code server and SSH
EXPOSE 8000 22

# Use our combined entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

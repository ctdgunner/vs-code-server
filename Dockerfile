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
    supervisor && \
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

# Create supervisor configuration for running both services
RUN echo '[supervisord]\n\
nodaemon=true\n\
user=root\n\
\n\
[program:sshd]\n\
command=/usr/sbin/sshd -D\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/sshd.err.log\n\
stdout_logfile=/var/log/sshd.out.log\n\
\n\
[program:vscode]\n\
command=code serve-web --without-connection-token --accept-server-license-terms --host 0.0.0.0 --port 8000 --cli-data-dir /root/.vscode/cli-data --user-data-dir /root/.vscode/user-data --server-data-dir /root/.vscode/server-data --extensions-dir /root/.vscode/extensions\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/vscode.err.log\n\
stdout_logfile=/var/log/vscode.out.log' > /etc/supervisor/conf.d/supervisord.conf

# Expose ports for VS Code server and SSH
EXPOSE 8000 22

# Use supervisor to run both SSH and VS Code server
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

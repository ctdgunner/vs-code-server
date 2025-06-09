FROM ahmadnassri/vscode-server:latest

# Install common dev tools + OpenSSH
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create SSH run directory and set root password (optional)
RUN mkdir /var/run/sshd && echo 'root:devpassword' | chpasswd

# Allow root login (optional, safer with key-based login)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Start SSH server by default
CMD ["/usr/sbin/sshd", "-D"]

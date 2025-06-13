#!/bin/bash

# Set SSH password from environment variable (default to 'password' if not set)
SSH_PASSWORD=${SSH_PASSWORD:-password}
echo "root:$SSH_PASSWORD" | chpasswd

# Create .gitconfig from environment variables if they exist
if [ ! -z "$GIT_USER_NAME" ] || [ ! -z "$GIT_USER_EMAIL" ]; then
    echo "Setting up git configuration..."
    
    if [ ! -z "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
    fi
    
    if [ ! -z "$GIT_USER_EMAIL" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
    fi
    
    echo "Git configuration complete."
fi

# Configure SSH environment to use same VS Code directories
echo 'export VSCODE_IPC_HOOK_CLI=/root/.vscode/cli-data' >> /root/.bashrc
echo 'export VSCODE_SERVER_DATA_DIR=/root/.vscode/server-data' >> /root/.bashrc
echo 'export VSCODE_USER_DATA_DIR=/root/.vscode/user-data' >> /root/.bashrc
echo 'export VSCODE_EXTENSIONS_DIR=/root/.vscode/extensions' >> /root/.bashrc

# Start SSH daemon in background
/usr/sbin/sshd -D &

# Start VS Code server in foreground
exec code serve-web --without-connection-token --accept-server-license-terms --host 0.0.0.0 --port 8000 --cli-data-dir /root/.vscode/cli-data --user-data-dir /root/.vscode/user-data --server-data-dir /root/.vscode/server-data --extensions-dir /root/.vscode/extensions
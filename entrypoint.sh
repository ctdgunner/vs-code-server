#!/bin/bash

# Set default PUID/PGID to 99:100 (Unraid nobody:users) if not specified
PUID=${PUID:-99}
PGID=${PGID:-100}

echo "Setting up container with PUID=$PUID and PGID=$PGID"

# Update vscode user/group IDs if they differ from current settings
CURRENT_UID=$(id -u vscode 2>/dev/null || echo 99)
CURRENT_GID=$(id -g vscode 2>/dev/null || echo 100)

if [ "$CURRENT_GID" != "$PGID" ]; then
    echo "Updating vscode group ID to $PGID"
    groupmod -o -g "$PGID" vscode
fi

if [ "$CURRENT_UID" != "$PUID" ]; then
    echo "Updating vscode user ID to $PUID"
    usermod -o -u "$PUID" vscode
fi

# Set SSH password from environment variable (default to 'password' if not set)
SSH_PASSWORD=${SSH_PASSWORD:-password}
echo "vscode:$SSH_PASSWORD" | chpasswd

# Fix permissions on home directory and mounted volumes
echo "Fixing permissions on /home/vscode and /projects..."
chown -R vscode:vscode /home/vscode 2>/dev/null || true
chown vscode:vscode /projects 2>/dev/null || true

# Create .gitconfig from environment variables if they exist (as vscode user)
if [ ! -z "$GIT_USER_NAME" ] || [ ! -z "$GIT_USER_EMAIL" ]; then
    echo "Setting up git configuration..."

    if [ ! -z "$GIT_USER_NAME" ]; then
        gosu vscode git config --global user.name "$GIT_USER_NAME"
    fi

    if [ ! -z "$GIT_USER_EMAIL" ]; then
        gosu vscode git config --global user.email "$GIT_USER_EMAIL"
    fi

    echo "Git configuration complete."
fi

# Start SSH daemon in background (runs as root, but only vscode user can login)
/usr/sbin/sshd -D &

# Start VS Code server as vscode user in foreground
echo "Starting VS Code server as vscode user..."
exec gosu vscode code serve-web --without-connection-token --accept-server-license-terms --host 0.0.0.0 --port 8000 --cli-data-dir /home/vscode/.vscode-server/cli-data --user-data-dir /home/vscode/.vscode-server/user-data --server-data-dir /home/vscode/.vscode-server/server-data --extensions-dir /home/vscode/.vscode-server/extensions
#!/bin/bash
set -euo pipefail

STATE_DIR="/var/lib/webobs-docker"
MARKER="$STATE_DIR/.initialized"
mkdir -p "$STATE_DIR"
WO_USER=$(stat -c '%U' ${INSTALL_DIR}/CONF)

set_password() {
    local user="$1" env_var="$2"
    local secret_file="/run/secrets/${env_var,,}"
    local password=""

    if [[ -f "$secret_file" ]]; then
        password="$(<"$secret_file")"
    elif [[ -n "${!env_var:-}" ]]; then
        password="${!env_var}"
    elif [[ ! -f "$MARKER" ]]; then
        password="$(openssl rand -base64 18)"
        echo "[entrypoint] Password generated for '${user}' : ${password}"
        echo "[entrypoint] Store it securely, it will not be displayed again."
    fi

    if [[ -n "$password" ]]; then
        echo "${user}:${password}" | chpasswd
    fi
}

if [[ ! -f "$MARKER" ]]; then
    set_password root ROOT_PASSWORD
    id "$WO_USER" &>/dev/null && set_password "$WO_USER" WO_PASSWORD
    touch "$MARKER"
fi

# echo "[entrypoint] Starting Apache "
apache2ctl start || echo "Error starting Apache: /var/log/apache2/error.log" >&2
 
# echo "[entrypoint] Starting postboard and scheduler "
su - "$WO_USER" -c "cd ${INSTALL_DIR} && CODE/shells/postboard start && CODE/shells/scheduler start"

echo "[entrypoint] Starting : $*"
exec "$@"
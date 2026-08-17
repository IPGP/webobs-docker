#!/bin/bash
set -euo pipefail

STATE_DIR="/var/lib/webobs-docker"
MARKER="$STATE_DIR/.initialized"
mkdir -p "$STATE_DIR"

if [ -d "${INSTALL_DIR}/CONF" ]; then
    WO_USER=$(stat -c '%U' "${INSTALL_DIR}/CONF")
else
    WO_USER="wo"
fi

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
    	OUTFILE="${INSTALL_DIR}/CONF/.wo_generated_password"
		echo "${password}" > "${OUTFILE}"
		chmod 600 "${OUTFILE}"
		chown "${WO_USER}:${WO_USER}" "${OUTFILE}" 2>/dev/null || true
		echo "**** No WO_USERPASSWD[_FILE] provided: a random password was generated"
		echo "**** for WebObs user '${WO_USER}' and written to:"
		echo "****     ${OUTFILE}  (on the host, if that directory is a mounted volume)"
		echo "**** Retrieve it with e.g.: docker exec <container> cat ${OUTFILE}"
    fi

    if [[ -n "$password" ]]; then
        echo "${user}:${password}" | chpasswd
    fi

    #TODO : add htpasswd command for wo (check if htpasswd file exists, if not create it)

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
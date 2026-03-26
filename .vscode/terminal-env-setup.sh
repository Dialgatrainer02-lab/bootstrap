# VS Code integrated terminal startup file.
# Loads the user's normal bash config and then exports variables from workspace .env.

if [ -f "${HOME}/.bashrc" ]; then
  . "${HOME}/.bashrc"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${WORKSPACE_DIR}/.env"

if [ -f "${ENV_FILE}" ]; then
  set -a
  . "${ENV_FILE}"
  set +a
fi

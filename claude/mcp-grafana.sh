#!/bin/sh
# Launcher for the Grafana MCP server.
#
# Exists so the server definition can live in this repo without the service
# account token living here too. ~/.claude.json is Claude Code's mutable state
# file and cannot be symlinked, so it holds only a pointer at this script.
#
# The token is read from 1Password at spawn time rather than exported from
# .zshrc, so it costs one unlock when Claude Code starts a session, not one on
# every shell. macOS only -- the servers have neither `op` nor the desktop app.

set -eu

GRAFANA_TOKEN_REF="${GRAFANA_TOKEN_REF:-op://Private/Grafana MCP/credential}"

if ! command -v op >/dev/null 2>&1; then
    echo "mcp-grafana: 1Password CLI (op) not found; install with 'brew install --cask 1password-cli'" >&2
    exit 1
fi

GRAFANA_SERVICE_ACCOUNT_TOKEN="$(op read "$GRAFANA_TOKEN_REF")" || {
    echo "mcp-grafana: could not read $GRAFANA_TOKEN_REF from 1Password" >&2
    exit 1
}
export GRAFANA_SERVICE_ACCOUNT_TOKEN
export GRAFANA_URL="${GRAFANA_URL:-https://grafana.akron.internal.zerpzorp.com}"

# ponytail: -disable-write keeps this read-only; drop it only with a token scoped to match.
exec mcp-grafana -disable-write

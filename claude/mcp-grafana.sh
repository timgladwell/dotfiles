#!/bin/sh
# Launcher for the Grafana MCP server.
#
# Exists so the server definition can live in this repo without the service
# account token living here too. ~/.claude.json is Claude Code's mutable state
# file and cannot be symlinked, so it holds only a pointer at this script.
#
# The token is read from 1Password at spawn time rather than exported from
# .zshrc, so it costs one approval when a session starts the server rather than
# one on every shell. macOS only -- the servers have neither `op` nor the
# desktop app.

set -eu

GRAFANA_TOKEN_REF="${GRAFANA_TOKEN_REF:-op://Private/Grafana MCP/credential}"
# Kept under Claude Code's 30s MCP startup budget so the error below wins the
# race and the caller gets a reason instead of a bare connection timeout.
GRAFANA_TOKEN_WAIT="${GRAFANA_TOKEN_WAIT:-25}"

if ! command -v op >/dev/null 2>&1; then
    echo "mcp-grafana: 1Password CLI (op) not found; install with 'brew install --cask 1password-cli'" >&2
    exit 1
fi

# A cold `op` session raises a touch-to-approve prompt on the desktop app and
# blocks until it is answered. macOS has no timeout(1), so perl provides the
# alarm; being killed by it exits 142 (128 + SIGALRM).
status=0
GRAFANA_SERVICE_ACCOUNT_TOKEN="$(
    perl -e 'alarm shift; exec @ARGV' "$GRAFANA_TOKEN_WAIT" op read "$GRAFANA_TOKEN_REF"
)" || status=$?

if [ "$status" -ne 0 ]; then
    if [ "$status" -eq 142 ]; then
        echo "mcp-grafana: the 1Password approval prompt went unanswered for ${GRAFANA_TOKEN_WAIT}s." >&2
        echo "  Nothing is wrong with Grafana or this server -- the token was never read." >&2
        echo "  Approve the prompt, then reconnect the server with /mcp." >&2
    else
        echo "mcp-grafana: could not read $GRAFANA_TOKEN_REF from 1Password (op exit $status)." >&2
        echo "  Check the item exists, or set GRAFANA_TOKEN_REF to the right vault path." >&2
    fi
    exit "$status"
fi

export GRAFANA_SERVICE_ACCOUNT_TOKEN
export GRAFANA_URL="${GRAFANA_URL:-https://grafana.akron.internal.zerpzorp.com}"

# ponytail: -disable-write keeps this read-only; drop it only with a token scoped to match.
exec mcp-grafana -disable-write

#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# PreToolUse hook: only allow MCP calls to the connectors this
# project is built around. Blocks every other MCP server, including
# unrelated connectors that may be authorized on a given machine.
#
# TEMPLATE — CUSTOMIZE THE ALLOWLIST BELOW.
# Each entry is a case-insensitive substring matched against the
# full tool name (format: mcp__<SERVER_NORMALIZED>__<tool_name>).
# Substring matching survives small naming differences between
# claude.ai and Claude Desktop connector setups. If a connector you
# legitimately use gets blocked, add a term here rather than
# disabling this hook. Edit this file OUTSIDE a Claude Code session
# (guard-settings-integrity.sh blocks in-session edits).
#
# FAIL-CLOSED: no match, or any error, denies the call.
# ---------------------------------------------------------------

ALLOWED_TERMS=(
  "pigment"   # <replace/narrow: e.g. part of your workspace's connector name to pin one Pigment workspace>
  # "slack"
  # "google_drive"
)

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

deny() {
  echo "${1:-MCP server call blocked}" >&2
  exit 2
}

contains_ci() {
  local haystack needle
  haystack="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  needle="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"
  [[ "$haystack" == *"$needle"* ]]
}

main() {
  INPUT="$(cat)"
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name')" || return 1

  # Only guard MCP tool calls
  if [[ "$TOOL_NAME" != mcp__* ]]; then
    echo '{}'
    exit 0
  fi

  for term in "${ALLOWED_TERMS[@]}"; do
    if contains_ci "$TOOL_NAME" "$term"; then
      echo '{}'
      exit 0
    fi
  done

  deny "MCP blocked: '$TOOL_NAME' is not an allowed connector for this project — see CLAUDE.md. If this connector is legitimately part of the workflow, add a matching term to ALLOWED_TERMS in .claude/hooks/guard-mcp-servers.sh (outside a Claude Code session)."
}

# Run main; if it fails for ANY reason, deny (fail-closed)
if ! main; then
  echo "MCP guard hook encountered an internal error — denying call." >&2
  exit 2
fi

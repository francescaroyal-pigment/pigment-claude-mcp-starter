#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# PreToolUse hook: block Write/Edit to this project's own Claude Code
# config, so a session can't quietly disable the MCP allowlist hook
# (guard-mcp-servers.sh) or its own settings.json wiring.
#
# FAIL-CLOSED: any error denies the call.
# ---------------------------------------------------------------

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

deny() {
  echo "${1:-Access denied by guard-settings-integrity hook}" >&2
  exit 2
}

resolve_path() {
  local p="$1"
  if [[ -e "$p" ]]; then
    realpath "$p" 2>/dev/null || echo "$p"
  else
    echo "$p"
  fi
}

main() {
  INPUT="$(cat)"

  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')" || return 1
  [[ -z "$FILE_PATH" ]] && { echo '{}'; exit 0; }

  CWD="$(echo "$INPUT" | jq -r '.cwd // empty')" || return 1
  [[ -z "$CWD" ]] && CWD="$(pwd)"

  RESOLVED="$(resolve_path "$FILE_PATH")"
  PROTECTED_DIR="$(resolve_path "$CWD/.claude/hooks")"
  PROTECTED_SETTINGS="$(resolve_path "$CWD/.claude/settings.json")"
  PROTECTED_SETTINGS_LOCAL="$(resolve_path "$CWD/.claude/settings.local.json")"

  if [[ "$RESOLVED" == "$PROTECTED_SETTINGS" || "$RESOLVED" == "$PROTECTED_SETTINGS_LOCAL" ]]; then
    deny "Blocked: $FILE_PATH is this project's Claude Code security config. Edit it by hand outside a Claude Code session if it genuinely needs to change."
  fi

  if [[ "$RESOLVED" == "$PROTECTED_DIR"/* ]]; then
    deny "Blocked: $FILE_PATH is inside .claude/hooks/ — these enforce the MCP allowlist for this project and shouldn't be edited from within a session. Edit by hand outside Claude Code if it genuinely needs to change."
  fi

  echo '{}'
}

if ! main; then
  echo "guard-settings-integrity hook encountered an internal error — denying call." >&2
  exit 2
fi

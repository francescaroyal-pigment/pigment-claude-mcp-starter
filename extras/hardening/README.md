# Optional hardening — connector guard hooks

**Not wired in by default.** The base starter relies on Claude Code's built-in permission prompts, which is the right level of friction for most setups: one Pigment connector, every write asks first.

## When you'd want this

- Your account has **multiple connectors authorized** (several Pigment workspaces, Slack, Drive, connectors from unrelated projects) and you want a hard guarantee this project only ever talks to its own.
- You use **Test/Deploy environments** and run separate dev and prod connectors — pinning each repo to its connector prevents the worst failure mode (a write landing in the wrong workspace).
- You or your team run Claude Code with **permissive settings** (auto-approved MCP calls), removing the human-in-the-loop that the default prompts provide.

If none of those apply, skip this — it's the #1 source of mysterious "everything is blocked" setup failures when the allowlist doesn't match a connector's exact name.

## What's here

| File | What it does |
|---|---|
| `guard-mcp-servers.sh` | A `PreToolUse` hook that blocks every MCP tool call except connectors matching an allowlist you edit at the top of the script. **Fail-closed:** no match, or any internal error, denies the call. |
| `guard-settings-integrity.sh` | Blocks Claude from editing `.claude/settings.json` or the hooks themselves mid-session, so the allowlist can't be quietly disabled. Only needed if the first hook is enabled — they're a package deal. |

## How to enable

Do all of this **outside a Claude Code session** (by hand in a plain editor/terminal):

1. Copy both scripts to `.claude/hooks/` at the repo root and make them executable:

   ```
   mkdir -p .claude/hooks
   cp extras/hardening/guard-*.sh .claude/hooks/
   chmod +x .claude/hooks/guard-*.sh
   ```

2. Edit the `ALLOWED_TERMS` list at the top of `.claude/hooks/guard-mcp-servers.sh` to match your connectors' names (case-insensitive substring match against the MCP tool name).

3. Wire the hooks into `.claude/settings.json` (create it if it doesn't exist):

   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "mcp__.*",
           "hooks": [{ "type": "command", "command": "./.claude/hooks/guard-mcp-servers.sh" }]
         },
         {
           "matcher": "Write|Edit",
           "hooks": [{ "type": "command", "command": "./.claude/hooks/guard-settings-integrity.sh" }]
         }
       ]
     }
   }
   ```

4. Commit `.claude/hooks/` and `.claude/settings.json` so every clone gets the same enforcement automatically.

## Finer-grained: per-tool permissions

The allowlist decides *which connectors* Claude may talk to; Claude Code's own `permissions` settings decide *which tool calls* run without asking. A sensible posture for a proven workflow — reads flow, writes still get a look:

```json
{
  "permissions": {
    "allow": [
      "mcp__your_pigment_connector__get_list_items",
      "mcp__your_pigment_connector__query_data",
      "mcp__your_pigment_connector__search"
    ],
    "ask": [
      "mcp__your_pigment_connector__add_list_items",
      "mcp__your_pigment_connector__set_metric_input"
    ]
  }
}
```

Use your connector's actual `mcp__<server>__` prefix; `mcp__<server>` with no tool name covers every tool on that connector. Loosen toward `allow` for writes only once the workflow has earned it.

## Known limits

- The integrity hook covers the `Write`/`Edit` tools but not `Bash`, so a shell command could still overwrite the config. Fine for a sandbox with no secrets; if your repo handles sensitive data or credentials, you'll want a heavier setup (OS-level sandboxing, secrets management) than this starter provides.
- `PreToolUse` hooks can enforce anything you can script — block writes while pointed at a prod connector, require a validation step before submission, log every write call. If you add one, keep the fail-closed shape of the two here (any internal error denies the call).

---
name: check-setup
description: Use this skill when someone new to this project wants to verify their MCP connections work before running the workflow. Triggers on phrases like "check my setup", "am I connected", "verify my access", "/check-setup", "is this working", or when a first-time user asks "how do I know I'm set up right".
version: 1.0.0
---

# Check Setup

This project has no local config to generate — "setup" here means: **do your MCP connectors work, and is the pigment plugin installed?** Each person authorizes their own connectors in their own claude.ai / Claude Desktop account, so this is a per-person check, not a one-time project step.

Read [CLAUDE.md](../../../CLAUDE.md) at the project root first if you haven't this session — it has the app ID, and [REGISTRY.md](../../../REGISTRY.md) has the block IDs referenced below.

## What to check

### 1. The pigment plugin

Check whether `pigment:*` skills are available in this session. If not, the plugin isn't installed — fix: in Claude Code, open the `/plugin` menu, add the `gopigment/ai-plugins` marketplace, and install the `pigment` plugin.

### 2. Pigment connector

Run one lightweight, **read-only** call — don't guess based on tool availability alone, actually call it: `get_list_items` on <the main list from REGISTRY.md> (`limit: 1`) against the application ID in CLAUDE.md.

- **Pass:** returns data.
- **Fail — tool not found:** the Pigment MCP connector isn't authorized in this account. Fix: in claude.ai / Claude Desktop connector settings, add the connector named in CLAUDE.md and complete the OAuth flow (run `/setup-connectors` for the walkthrough).
- **Fail — tool found but access error:** connector is authorized but this account lacks access to the app. Fix: ask the app owner to grant access.

If this account has **multiple Pigment connectors** (e.g. dev and prod from Test/Deploy environments), confirm the one that responded is the one named in CLAUDE.md — a passing check against the wrong workspace is worse than a failure.

### 3. <Other connector(s), if any>

<!-- One read-only probe per additional connector (Slack: read the channel;
     Google Drive: search for the registered sheet from data-sources/README.md),
     with the same three-way pass/fail breakdown. Delete if Pigment-only. -->

## What this check can't catch: Advanced Tools

These calls are all **read-only**, so they can't detect whether the user has turned on **Advanced Tools** in Pigment (Settings → Advanced features → "Enable advanced tools on MCP server", off by default, per-user). Write calls (`add_list_items`, `set_metric_input`) need it — without it, this check reports a clean pass and the first write still fails. Mention this explicitly in the report rather than letting a clean pass imply everything works.

## Reporting the result

Give a short pass/fail summary, e.g.:

```
pigment plugin:               ✅ installed
Pigment (<connector name>):   ✅ connected (<app name> reachable)
<Other connector>:            ❌ not connected — connector not authorized
```

Always add the Advanced Tools caveat, even when everything passes. If something fails, give the specific fix from above — don't just say "check your connectors."

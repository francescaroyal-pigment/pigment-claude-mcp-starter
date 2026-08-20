---
name: setup-connectors
description: Use this skill to walk a new user through connecting this project's external services, starting with the Pigment MCP endpoint. Triggers on phrases like "set up my connector", "connect to Pigment", "add the Pigment MCP endpoint", "/setup-connectors", "how do I get my Pigment MCP URL", "help me connect Pigment", "I need to authorize the Pigment connector".
version: 1.0.0
---

# Setup Connectors

Interactive walkthrough for getting this project's connectors authorized.

## Step 0 — the pigment plugin

Before anything else, confirm the user has the **`pigment` plugin** installed (README prerequisite #2): in Claude Code, open the `/plugin` menu, add the `gopigment/ai-plugins` marketplace, and install the `pigment` plugin. A quick tell: if no `pigment:*` skills are available in this session, the plugin isn't installed. Skills in this repo assume it.

## Step 1 — Pigment MCP endpoint

Work out which of these three situations applies. Ask directly if it's not obvious from what the user has already said — don't guess, since the fix is different in each case.

**A. The Pigment connector already exists somewhere (org-level or your own) — you just need to authorize/connect it.** → go to **1A**.

**B. Nobody has turned on MCP for your Pigment workspace yet.** → go to **1B** first, then come back to 1A or 1C.

**C. You want a personal, dev-only connector — separate from your org's shared one, e.g. pointed at a sandbox workspace, per this template's recommended "prove it in dev first" pattern.** → go to **1C**.

### 1A — Authorize an existing connector

1. On claude.ai: **Settings → Connectors**.
2. Look for the connector named in this project's [CLAUDE.md](../../../CLAUDE.md) (the "MCP connector" line). If that line still has a `<placeholder>` in it, stop and ask the user which connector name to use, then fill it in for them.
3. If it's listed: click **Connect**, sign in with Pigment credentials, then start a new chat and open **Connectors** to confirm it shows as active.
4. If it's **not** listed, someone with Owner privileges on claude.ai needs to add it first — see the "add custom connector" steps under 1B once you have the endpoint URL.
5. Back in Claude Code, reopen this project folder and run `/check-setup` to confirm the connection actually works (authorized ≠ working — `/check-setup` makes a real read-only call).

### 1B — Generate the MCP endpoint URL (admin-only, one-time per workspace)

Requires **Workspace Administrator**, **Security Administrator**, or **Primary Owner** in Pigment. If the user doesn't have one of these roles, tell them to ask whoever does — don't try to work around it.

1. In Pigment: **Workspace Settings → Integrations → MCP tab**.
2. Toggle on **MCP (Model Context Protocol)**.
3. Pigment generates a unique **MCP endpoint URL**. This is shared by every member of that workspace — one URL per workspace. **If the org uses Test/Deploy environments, each environment has its own URL** — modelers working across both will end up with two connectors (one dev, one prod); most users only need the one for the workspace where they work.
4. Copy that URL. Use it in **1A** (paste it into a new "custom connector" in claude.ai's Settings → Connectors, leaving OAuth Client ID/Secret blank — Pigment handles OAuth itself) or in **1C** below.

Treat the endpoint URL as credential-adjacent: don't paste it into this repo, a shared doc, or anywhere outside your own connector settings / shell.

### 1C — Add a personal CLI connector (dev/sandbox)

Use this when the org's shared connector points at production and you want to test a new workflow against a sandbox workspace first (see this repo's README, "One connector or two?").

```
claude mcp add --transport http pigment-dev <your-dev-workspace-MCP-endpoint-URL>
```

- Run it **inside this project folder** — the connector is scoped to wherever you added it from.
- Complete the auth prompt that follows.
- Reopen Claude Code / Claude Desktop **in the same folder**, then verify with `claude mcp list`.

### After connecting (any path)

1. Update the "MCP connector" line in [CLAUDE.md](../../../CLAUDE.md) with the exact connector name now showing up, so every session knows which connector this project uses.
2. Run `/check-setup`.
3. Remind the user of the one gap `/check-setup` can't see: **Advanced Tools** (Pigment → Settings → Advanced features → "Enable advanced tools on MCP server", off by default, per-user). Reads will pass without it; writes will fail on the first attempt.

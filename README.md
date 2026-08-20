# Pigment + Claude MCP Starter

A starter kit for getting started with Claude Code and the Pigment MCP connector — making it easy to set up Pigment MCP sessions with your whole team.

The goal: a **self-contained project for a specific workflow in your Pigment application** — one that keeps track of your work, streamlines your sessions, makes your workflows replicable, and is easy to share with your team: anyone who clones it is a `/start-project` away from a working Pigment MCP session. Copy this template per workflow, open Claude Code inside it, and run **`/start-project`** — Claude sets the project up with you as you work. You don't fill anything in by hand.

## What's in the box

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Operating instructions Claude Code loads automatically every session — your app, field rules, valid values, and the knowledge-system rules. Claude fills this in through `/start-project` and keeps it current as you work. |
| `REGISTRY.md` | Source of truth for your Pigment object IDs (apps, lists, metrics, boards). Claude reads this instead of re-querying Pigment, and updates it whenever it creates or changes something. |
| `KNOWLEDGE.md` | Durable learnings — connector gotchas, formula patterns, things that worked. Grows as you build. |
| `.claude/skills/` | Project-scoped skills: `start-project` (set up this project interactively), `setup-connectors` (authorize the Pigment MCP endpoint), `check-setup` (verify everything works), and `example-workflow` (a scaffold for your own write-to-Pigment workflow). |
| `.claude/commands/` | Slash-command shortcuts: `/start-project`, `/setup-connectors`, `/check-setup`. |
| `data-sources/` | Drop zone for reference data (CSV exports, sheets) — gitignored by default so your data never lands in a shared repo. |
| `extras/hardening/` | Optional security hooks for multi-connector setups. Not wired in by default — see [When to harden](#optional-hardening) below. |

## Getting started

### 1. Get the repo

Copy (or clone) this folder to a new name that describes your workflow — one copy per workflow. `git init` inside it if it isn't already a repo.

### 2. Per-person prerequisites

Everything here is **per-person** — there's no shared credential, and each item can silently be missing even if the others are fine:

1. **Claude Code installed** (CLI or the VS Code extension), signed in.
2. **The `pigment` plugin installed** from [gopigment/ai-plugins](https://github.com/gopigment/ai-plugins): in Claude Code, open the `/plugin` menu, add the `gopigment/ai-plugins` marketplace, and install the `pigment` plugin. This gives Claude the Pigment modeling, formula, and data-import knowledge this starter assumes — without it, Claude is guessing at Pigment syntax.
3. **Advanced tools enabled in Pigment** — Settings → Advanced features → **"Enable advanced tools on MCP server."** Off by default, set per-user. Without it, write calls (`add_list_items`, `set_metric_input`) fail even when everything else is connected — see [Pigment's supported-tools docs](https://kb.pigment.com/docs/supported-tools).
4. **Access to your target Pigment application** — being able to authorize the connector and having rights on the app are two different failure modes.
5. **The Pigment MCP connector authorized** in your claude.ai / Claude Desktop connector settings. Run **`/setup-connectors`** for an interactive walkthrough (generating the endpoint URL if your workspace doesn't have one yet, authorizing it, or adding a personal dev connector).

### One connector or two?

- **Most users have exactly one connector** — the one pointed at the production workspace where they work.
- **If your organization uses Pigment's Test/Deploy environments and you're a modeler who wants to connect to the dev (Test) environment**, that environment has its **own MCP endpoint URL** — the prod connector can't see it. You'll end up with **two connectors: one for dev, one for prod**. Connect the dev one for this project (that's the recommended place to prove out a new workflow — write calls are real writes), note its exact name in `CLAUDE.md`, and double-check which connector you're pointed at before any write. `/setup-connectors` path **1C** covers adding a personal dev connector.

### 3. Run `/start-project`

Open Claude Code in this folder and run **`/start-project`**. Claude asks what the project is for and which Pigment application it targets, then does the setup itself: verifies your connection, looks up the application and block IDs over MCP, records them in `REGISTRY.md`, pulls real valid values from your dimensions, and writes it all into `CLAUDE.md`.

You don't need to have everything figured out up front — whatever isn't known yet gets filled in naturally as you work, because `CLAUDE.md` tells Claude to keep the project files current in every session.

### 4. Verify

Run **`/check-setup`** any time (new teammate, new machine, something feels off). It makes one real read-only call per connector and reports pass/fail with the specific fix. One gap it can't catch: the Advanced Tools setting (prerequisite #3) looks fine on read-only checks and only surfaces the first time a write fails — if setup passes but a write fails, check that setting first.

### 5. Build your workflow skill

A skill is a `SKILL.md` file under `.claude/skills/<name>/` — YAML frontmatter (`name`, `description` with trigger phrases) plus step-by-step instructions. Start from `example-workflow/SKILL.md`, a generic "collect fields → write to Pigment → confirm" scaffold.

**Don't write skills from scratch — earn them.** Run the workflow manually in a Claude Code session first, watch which tools Claude calls and where it stumbles, correct it until the run is clean, and *then* say "now make this a skill." A skill is a validated workflow written down, not a spec written hopefully. While validating, test the failure paths too — deliberately submit an invalid dimension combination and confirm the error handling does what your skill says it should.

Rules of thumb for reliable skills:

- Keep shared reference data in `CLAUDE.md` + `REGISTRY.md` and have every skill point at it — one source of truth.
- Spell out **which fields go where** (settable at row creation vs. set via a metric input afterwards) — the #1 thing Claude will otherwise guess wrong.
- Give explicit validation rules ("never invent a dimension item — stop and ask") and ordering rules ("set the Submitted flag last").
- Batch writes when handling multiple items — one `add_list_items` call, then batched `set_metric_input` calls.

## The local knowledge system

Three files keep Claude fast, keep your work replicable, and stop it re-querying Pigment for things it already knows:

| File | Role |
|---|---|
| `CLAUDE.md` | Operating rules, field rules, valid values — auto-loaded every session |
| `REGISTRY.md` | Object IDs and structure — read before querying Pigment, updated in the same turn as any create/rename/delete |
| `KNOWLEDGE.md` | Durable learnings — connector behavior, formula patterns, gotchas |

Claude maintains all three as a side effect of normal work — that's what makes the project shareable: a teammate who clones it inherits the IDs, the rules, and the lessons learned, not just the code.

## Getting data in

For pushing external data (spreadsheets, CSV exports) into Pigment through this repo, see [data-sources/README.md](data-sources/README.md) — it covers dropped files, live-connected sources, and when to skip the LLM entirely and use Pigment's import API.

## Optional hardening

By default this starter relies on Claude Code's built-in permission prompts — every MCP write asks before it runs, which is the right level of friction for a single-connector setup.

If your machine has **multiple connectors authorized** (several Pigment workspaces, or dev + prod), consider the optional guard hooks in [extras/hardening/](extras/hardening/README.md): a connector allowlist that blocks every MCP server except the one this project uses, plus an integrity guard so the allowlist can't be edited away mid-session. That's what stops Claude from reaching for the wrong workspace — most valuable when you're running with permissive settings or pointing dev and prod repos at different connectors.

## When NOT to use this

This is a **playground shape, not a production harness**. It has no secrets management and no filesystem sandbox. If you're building something that touches sensitive data or credentials — or a bulk/deterministic pipeline — talk to your Pigment contact about the right foundation before building on this.

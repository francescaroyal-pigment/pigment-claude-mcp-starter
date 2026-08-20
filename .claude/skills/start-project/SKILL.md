---
name: start-project
description: Use this skill to set up a fresh copy of this starter as a real project. Triggers on "/start-project", "set up this project", "let's get started", "initialize this project", or any first session where CLAUDE.md still contains unfilled <PLACEHOLDER> values.
version: 1.0.0
---

# Start Project

Turn a fresh copy of the starter into a working project — interactively, with the user, in one session. The user should never have to hand-edit placeholders: you ask, you look things up over MCP, you write the files.

**Tone:** this is likely the user's first session in this repo, and possibly their first time using Claude Code with Pigment. Keep it conversational — a few questions, then do the work. Don't dump the whole checklist on them.

## Step 1 — Ask what this project is

Two questions (skip anything already obvious from what the user said):

1. **What workflow is this project for?** (e.g. "submitting seat requests", "monthly headcount updates", "pushing pipeline data from a sheet") — one line.
2. **Which Pigment application does it target?** By name is fine.

## Step 2 — Verify the connection

Confirm a Pigment MCP connector responds (one lightweight call, e.g. `get_applications`). If no Pigment tools are available or the call fails, switch to the `setup-connectors` skill, get connected, then come back here. Also confirm `pigment:*` skills are available — if not, walk the user through installing the `pigment` plugin (README prerequisite #2) before continuing.

## Step 3 — Look everything up (don't ask the user for IDs)

Using the connector:

1. `get_applications` → find the named application, record its ID.
2. `get_organization_info` → record the organization ID in `REGISTRY.md`.
3. Ask the user which lists/blocks the workflow touches (or infer from their workflow description), then `search` / `filtered_search` for them and record each ID in the right `REGISTRY.md` table.
4. For each dimension the workflow validates against, `get_list_items` and record the real values in `CLAUDE.md`'s **Valid values** section.

## Step 4 — Write the files

1. **CLAUDE.md:** replace every `<PLACEHOLDER>` with real values — workflow name, description, application name + ID, exact connector name. Fill "Which fields go where" and "Submission rules" with what's known so far; leave honest `(to be confirmed)` notes where something hasn't been validated yet. Delete the template comments.
2. **REGISTRY.md:** connector name, org ID, block rows from step 3, and set the "Last updated" line.
3. Leave `KNOWLEDGE.md` alone — it fills itself as lessons are learned.

It's fine for the setup to be partial. Whatever isn't known yet gets filled in during real work — CLAUDE.md's operating rules require keeping these files current in every session, so gaps close naturally.

## Step 5 — Confirm and point forward

Report a short summary: application + ID, blocks registered, valid-value lists captured, anything left `(to be confirmed)`. Then suggest the natural next steps:

1. Run `/check-setup` (or note you effectively just did the read check).
2. Do one small real read and one small write, confirmed in the Pigment UI.
3. Run the actual workflow manually a few times, then say "make this a skill" — see README, "Build your workflow skill."

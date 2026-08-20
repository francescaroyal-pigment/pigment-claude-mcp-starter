---
name: example-workflow
description: TEMPLATE — replace with your workflow. Use this skill when the user wants to <create/submit/sync X> in <your Pigment application>. Triggers on phrases like "<add a …>", "<new … request>", or similar. List the real phrases your users will type — the description is how Claude decides to invoke the skill.
version: 1.0.0
---

<!-- TEMPLATE: this is the anatomy of a reliable write-to-Pigment skill.
     Rename the folder, rewrite each section for your workflow, and delete
     these comments. Remember: earn skills by validating the workflow
     manually first (see README, "Build your workflow skill"). -->

# <Workflow name> — <Pigment application name>

Full workflow for <what this does>. Validation rules and valid values live in [CLAUDE.md](../../../CLAUDE.md) at the project root, block IDs in [REGISTRY.md](../../../REGISTRY.md) — read those first if you haven't already this session.

## Required fields

Collect all of these before proceeding. Do not write anything until all are provided (or explicitly confirmed as skipped by the user).

| Field | Type | Notes |
| --- | --- | --- |
| <Field 1> | Reference | Must match an item in the <X> dimension |
| <Field 2> | Reference | Manual input — watch for natural-language phrasing like "<on engineering>", "<in marketing>" |
| <Field 3> | Date | Format `YYYY-MM-DD`, <constraint, e.g. must be strictly in the future> |

## Workflow

Execute in order once all required fields are collected.

### Step 1 — Create the row

Call `add_list_items` on <the main list> (ID in REGISTRY.md):
- `headers`: only the properties that are settable at creation (see "Which fields go where" in CLAUDE.md)
- `rows`: one row with the provided values

Do **not** include computed properties (they're set via metrics in the next steps) and do **not** set auto-generated IDs.

### Step 2 — Identify the new row

Call `get_list_items` on the list. <How to find it — e.g. sequential IDs mean the new row has the highest ID.> Note its display name.

### Step 3+ — Set each input metric

One `set_metric_input` call per metric, using the row's display name:
`dimension_display_names: ["<dimension>"]`, `rows: [{ dimension_values: ["<row display name>"], metric_value: { type: "<Dimension|Date|Boolean|Number>", value: <value> } }]`

Order matters: set any **status/submit flag last**, once everything else is confirmed valid.

## Auto-execute rule

If the user provides every required field in a single message, execute all steps without asking for confirmation. Only pause when a field is missing, ambiguous, or doesn't match the valid-values lists in CLAUDE.md.

## Batching

With multiple items, add all rows in a single `add_list_items` call, then batch the `set_metric_input` calls (one row per item) — faster than one-at-a-time.

## Confirming success

Report back a table of what was created:

| Field | Value |
| --- | --- |
| <ID> | ... |
| <Field 1> | ... |
| Status | <e.g. Submitted — awaiting approval> |

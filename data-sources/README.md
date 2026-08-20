# data-sources/

Where external reference data for this workflow lives — both **files dropped here** and **notes on live connected sources** (Google Sheets, Drive docs, etc.).

The headline use case: a user says *"here's my spreadsheet — push this into Pigment."* Claude acts as the intermediary — it reads the sheet (or a dropped export), validates each row against the valid-values lists in `CLAUDE.md`, flags invalid dimension combinations for the user to fix or remap, and writes the clean rows via MCP. This works well up to roughly 1,000 lines per push (the limit is the model's context window, not Pigment); beyond that, use the API import path at the bottom of this file.

## Three ways to get data in

### Option A — drop a file here (simplest)

Export from the source (Google Sheets → File → Download → CSV) and save it in this folder. Claude Code can read it directly, validate it, and push it into Pigment (the `pigment` plugin's data-import skill handles CSV → list/dimension mapping).

Good for: one-off imports, bulk uploads, snapshots you want under version control.

**Careful with git:** this folder is gitignored by default (see the repo's `.gitignore`) except for this README — data files often contain names/salaries/etc. that don't belong in a shared repo. Deliberately un-ignore a file only if it's safe to share with everyone who can clone the repo.

### Option B — connect the source live (no manual export)

Authorize the relevant connector in your claude.ai / Claude Desktop connector settings — e.g. **Google Drive** for Sheets and Docs. Then Claude can read the sheet directly by name/URL each run, so the data is never stale and nobody has to remember to re-export.

When you add a live source, **document it below** so every session knows what it is and how to read it. (If you've enabled the optional connector-allowlist hook from `extras/hardening/`, also add the new connector to its allowlist.)

### Option C — Pigment API import (bulk / deterministic)

For large volumes or pipelines that must run identically every time (e.g. a "commit to Pigment" button in an app, a scheduled sync), skip the LLM in the write path entirely: create an import in Pigment from a sample CSV, persist the configuration, and script a POST of the file to the import's API endpoint. Claude Code is still useful here — for *writing* the script — but the data flows deterministically. Ask your Pigment contact for the import API documentation.

**API key hygiene, non-negotiable:**

- Pigment API keys are workspace-scoped and only a workspace admin can create them. Use a **scoped, import-only key** for import scripts — a full-access key in a script can read everything the workspace holds.
- **Never commit an API key to a repo** (this one or any other) — anyone who finds it can push data into your tables. Keep keys in a secrets manager or environment variables, and gitignore anything that holds them.

## Registered live sources

<!-- One entry per connected source. Example:

### Hiring plan sheet
- **What:** Google Sheet, one row per open role
- **Where:** <sheet URL or exact document name to search for>
- **Connector:** Google Drive
- **Columns that matter:** Role, Department, Start Date, Approver
- **Refresh expectation:** read live every run — never cache
-->

_None yet._

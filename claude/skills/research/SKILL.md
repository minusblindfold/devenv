---
name: research
description: Scan conventions and codebase to inform planning and design. Use when starting a new feature or when discoveries surface during implementation.
argument-hint: "[feature-slug or topic]"
allowed-tools: Read Bash Glob Grep
---

Scan conventions and codebase to produce structured context for the plan/design/implement cycle.

## Config

Read `~/.claude/devenv.json`. Keys: `work.dir` (default `.work`), `conventions.layers`.

## Mode

Parse `$ARGUMENTS`:

- Matches an existing file in `<work.dir>/research/` by slug → **re-entry** (append dated section).
- Set but no match → **create** new research file.
- Empty → **health-check** mode. Before starting, confirm with the user: "This will run a full project health check (all conventions + full codebase scan). This can take a while. Continue, or would you like to research a specific topic instead?" If they provide a topic, switch to create mode. If they confirm, proceed — writes to `<work.dir>/research/health-check.md`.

## Convention scan

Run `/resolve-conventions` to discover conventions:
- If topic provided → `mode:keyword <topic>` (match topic against frontmatter keywords).
- If health-check → `mode:all` (return every resolved convention).

If `/resolve-conventions` is unavailable, warn the user: "Convention resolution skill not found — conventions will not be applied. Run install.sh from your devenv repo to fix this." Then continue without conventions.

For each matched convention, extract:
- Title (H1 heading)
- Source layer path
- First 3–5 rules or key patterns

## Codebase scan

1. Read `CLAUDE.md` if present.
2. Scan project directory structure (top-level + key subdirectories).
3. Check for `<work.dir>/bootstrap.md` — read if found.
4. Search code for patterns relevant to the topic — look for existing implementations, inconsistencies, multiple approaches, tech choices.
5. Note anything that might affect planning or design.

## Output

Write to `<work.dir>/research/YYYY-MM-DD-<slug>-research.md` (or `health-check.md` for health-check mode).

```markdown
# <Topic> Research

## YYYY-MM-DD — <description>

### Applicable Conventions

| Convention | Source Layer | Key Rules |
|---|---|---|
| Title from H1 | layer path | first 3-5 rules |

### Codebase Patterns

- **Pattern:** <what was found>
- **Location:** <where>
- **Notes:** <consistency, alternatives, concerns>

### Gaps & Recommendations

- [ ] <actionable item>
```

## Re-entry

If appending to an existing file:
1. Read the existing file in full.
2. Append a new `## YYYY-MM-DD — <description>` section at the end.
3. Never overwrite or modify prior sections.

## Wrap up

- Summarise what was found: conventions matched, patterns observed, recommendations count.
- Suggest next steps:
  - `/plan` or `/plan <slug>` to start planning from findings.
  - `/plan refine` if recommendations affect an existing plan.
  - `/design` if a plan already exists and findings inform architecture.

## Rules

- Never implement. This skill produces context, not code.
- Never overwrite prior research sections on re-entry.
- Convention discovery must use the resolution algorithm — never hardcode paths.
- Keep recommendations actionable and scoped — avoid vague suggestions.
- If no conventions match and no relevant codebase patterns are found, say so clearly rather than padding the output.

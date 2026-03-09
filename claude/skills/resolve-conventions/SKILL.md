---
name: resolve-conventions
description: Resolve and return convention docs from configured layers. Called by other skills — not intended for direct use.
user-invocable: false
allowed-tools: Read, Glob, Grep
---

Discover and read convention docs across configured layers.

## Input

The calling skill passes context via $ARGUMENTS:

- `mode:all` — return every resolved convention doc.
- `mode:keyword <terms>` — match terms against frontmatter `keywords` arrays.
- `mode:explicit <title1>, <title2>` — match listed titles against H1 headings.
- Optional modifier: `scope:<value>` — filter results by the `scope` frontmatter field. Can be appended to any mode (e.g., `mode:all scope:bootstrap`).

If $ARGUMENTS is empty, default to `mode:all`.

## Resolution

1. Read `~/.claude/conventions/`. Find all `.md` files (excluding `conventions.md`, which is documentation, not a convention).
2. Read YAML frontmatter (between `---` delimiters) from each file.
3. Build a resolution map keyed by filename with: path, keywords (from frontmatter), title (from H1 heading).
4. For docs without frontmatter, use the H1 title and blockquote description for matching. These docs are still resolved but can only be matched by title.
5. If the directory is empty or missing, this is a valid state — proceed to output with no conventions.

## Matching

Apply the mode from $ARGUMENTS:

### all
Return every resolved doc.

### keyword
Scan each term against resolved docs' `keywords` arrays. Return all matches.

### explicit
Match each title against the H1 heading of resolved docs. Return all matches.

### Scope filtering

If a `scope:<value>` modifier is present in $ARGUMENTS, apply it as a post-filter after mode matching. Keep conventions where the frontmatter `scope` field matches the requested value OR equals `all`. Conventions with no `scope` field default to `all` and are always included.

Example: `mode:all scope:bootstrap` returns conventions with `scope: bootstrap`, `scope: all`, or no `scope` field. Conventions with `scope: feature` are excluded.

If no `scope` modifier is present, skip this filter — return all mode-matched conventions regardless of scope. This preserves backward compatibility.

## Output

Print: "Applying conventions: \<list of matched titles\> (from \<layer path\>)". If no conventions match, print: "No convention docs apply to this task."

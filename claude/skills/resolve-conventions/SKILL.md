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

1. Read `conventions.layers` from `~/.claude/devenv.json`. If missing, default to `["~/.claude/conventions"]`.
2. Walk layers in array order. First entry = highest precedence.
3. In each layer directory, find all `.md` files. Read YAML frontmatter (between `---` delimiters) from each.
4. Build a resolution map keyed by filename:
   - First occurrence of a filename → add it (path, keywords, title).
   - Subsequent occurrence → check the new doc's `extends` frontmatter:
     - `extends: true` → mark as extension. Read both: higher-precedence doc first, then this one appends.
     - `extends: false` or omitted → skip. Higher-precedence version already won.
5. For docs without frontmatter, use the H1 title and blockquote description for matching. These docs are still resolved but can only be matched by title.
6. Skip missing layer directories with a warning. Do not error.

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

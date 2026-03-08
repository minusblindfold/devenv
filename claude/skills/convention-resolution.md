# Convention resolution

Used by skills that need to discover and read convention docs across layers.

## Resolution

1. Read `conventions.layers` from `~/.claude/devenv.json`. If missing, default to `["~/.claude/skills/conventions"]`.
2. Walk layers in array order. First entry = highest precedence.
3. In each layer directory, find all `.md` files. Read YAML frontmatter (between `---` delimiters) from each.
4. Build a resolution map keyed by filename:
   - First occurrence of a filename → add it (path, keywords, title).
   - Subsequent occurrence → check the new doc's `extends` frontmatter:
     - `extends: true` → mark as extension. Skill reads both: higher-precedence doc first, then this one appends.
     - `extends: false` or omitted → skip. Higher-precedence version already won.
5. For docs without frontmatter, use the H1 title and blockquote description for matching. These docs are still resolved but can only be matched by title.
6. Skip missing layer directories with a warning. Do not error.

## Matching modes

### Explicit

The design's task spec has a `**Conventions:**` line listing convention titles. Match each title against the H1 heading of resolved docs. Read all matches.

### Keyword

Scan the task description for words that appear in any resolved doc's `keywords` array. Return all matches. This is the fallback when no explicit `**Conventions:**` line exists.

### All

Return every resolved doc. Used by `/bootstrap` to read all conventions.

## Output

After resolving and matching, print: "Applying conventions: \<list of matched titles\> (from \<layer path\>)". If no conventions match, print: "No convention docs apply to this task."

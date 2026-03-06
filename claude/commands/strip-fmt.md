Remove accidental formatting noise (whitespace, indentation, blank lines, comment rewrapping) from the current git diff, leaving intentional changes untouched.

## Arguments

`$ARGUMENTS` may contain:
- `--staged` — operate only on staged changes (`git diff --cached`)
- `--unstaged` — operate only on unstaged changes (`git diff`)
- Default (no flag): operate on both staged and unstaged

## Process

### 1. Parse scope

Read `$ARGUMENTS`. Set scope to `staged`, `unstaged`, or `both`.

### 2. Gather diffs

For each applicable scope, run:
- Unstaged: `git diff`
- Staged: `git diff --cached`

Also run the whitespace-ignoring variants:
- Unstaged: `git diff -w`
- Staged: `git diff --cached -w`

If there are no changes in the chosen scope, report "Nothing to strip." and stop.

Skip binary files and renamed/moved files entirely — do not touch them.

### 3. Classify each file

For each changed file in the diff:

**Whitespace check:** Compare the file's hunks in the normal diff vs. the `-w` diff.
- If all hunks disappear under `-w`: the file is **whitespace-only** → mark for full revert.
- If some hunks disappear but not all: the disappeared hunks are **whitespace-only** → mark those hunks for stripping.
- If no hunks disappear: proceed to comment check.

**Comment-only check** (for hunks that survive the whitespace check): Extract the changed lines (lines starting with `+` or `-`, excluding the `+++ / ---` header). Strip comment markers from both sides — language-agnostic patterns: `#`, `//`, `/*`, `*`, `*/`, `"""`, `'''`, `--`. Trim whitespace. If the stripped content of the removed lines equals the stripped content of the added lines, the hunk is **comment-reformatting only** → mark for stripping.

**Ambiguity guard:** If a hunk contains whitespace changes inside a string literal (detectable when the surrounding context lines show the change is inside quotes), or the comment content has changed in meaning after stripping markers, classify as **ambiguous** — leave it untouched and add it to the flagged list.

CRLF↔LF differences count as whitespace and are eligible for revert.

### 4. Revert formatting changes

**Whole-file formatting only:**
- Unstaged: `git restore <file>`
- Staged: `git restore --staged <file>`

**Mixed file (some real changes, some formatting):**
1. Parse the raw diff for the file.
2. Extract the formatting-only hunks (those marked in step 3).
3. Negate the hunk offsets to build a reverse patch: swap `+` and `-` lines, adjust `@@` line numbers accordingly.
4. Write the reverse patch to a temp file.
5. Apply with: `git apply -R --recount <tempfile>` (add `--cached` for staged scope).
6. If `git apply` fails, report the file as **not touched** and add it to the flagged list.

### 5. Report summary

Print a clear summary in three buckets:

```
Fully reverted (formatting only):
  - path/to/file.py

Hunks stripped (mixed — real changes preserved):
  - path/to/other.js  (2 hunks removed)

Flagged (not touched — review manually):
  - path/to/tricky.go  (ambiguous hunk at line 42)

Nothing to do:
  - path/to/clean.ts
```

If all files were clean, print: "No formatting noise found."

## Rules

- **Do less when uncertain.** Any hunk that is ambiguous is left alone and reported — never silently dropped.
- **Never touch files outside the chosen scope.** `--staged` must not affect the working tree; `--unstaged` must not affect the index.
- **Never commit.** This skill only modifies the working tree or index; committing is always the user's action.
- **Preserve intentional changes.** When in doubt about whether a change is formatting or intentional, leave it in the flagged bucket.

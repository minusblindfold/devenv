Rebase the current feature branch onto a configurable base with minimal friction. Auto-resolves trivial conflicts; only interrupts the user when a conflict is genuinely ambiguous.

## Arguments

`$ARGUMENTS` may contain an optional base branch override (e.g. `origin/main`). If not provided, read the default from config.

## Process

### 1. Determine base branch

If `$ARGUMENTS` is non-empty, use it as the base branch.

Otherwise, read from `~/.claude/devenv.json`:

```bash
jq -r '.rebase.defaultBase' ~/.claude/devenv.json
```

If that fails (file missing, key absent, jq unavailable), ask the user: "What base branch should I rebase onto?"

### 2. Check for a dirty working tree

Run `git status --porcelain`. If output is non-empty, warn the user:

```
Your working tree has uncommitted changes. Choose how to proceed:
1. Stash them now (git stash) and unstash after rebase
2. Abort — I'll clean up first
3. Proceed anyway (risky if the rebase touches the same files)
```

Wait for the user's choice. If they choose stash, run `git stash` and note to unstash at the end. If they choose abort, stop here.

### 3. Show what will be replayed

Run `git log --oneline <base>..HEAD` and print the list of commits about to be replayed, so the user knows what's coming.

### 4. Fetch and rebase

Run:
```bash
git fetch origin
git rebase <base>
```

If rebase exits 0 (clean): jump to step 6 (summary).

If rebase exits non-zero: proceed to conflict resolution (step 5).

### 5. Conflict resolution loop

Run `git status --porcelain` and collect all `UU` (both-modified) files.

For **each conflicted file**:

a. Read the file content and locate all conflict blocks (delimited by `<<<<<<<`, `=======`, `>>>>>>>`).

b. For each conflict block, classify it:

**Auto-resolve: whitespace-only side**
Strip all whitespace (spaces, tabs, newlines) from both the `ours` block and `theirs` block. If one side reduces to empty or both sides are identical after normalisation → take the non-empty side (or either if equal). Write the resolved content.

**Auto-resolve: purely additive**
If neither side deletes lines that the other side has (both sides only add lines relative to the base) → interleave: output the `ours` lines followed by the `theirs` lines (or vice versa if that order is more natural). Write the resolved content.

**Escalate: ambiguous**
Display the conflicting hunk with surrounding context (5 lines before/after):

```
Conflict in <file> (hunk N of M):

<<<<<<< ours
<ours lines>
=======
<theirs lines>
>>>>>>> theirs

How do you want to resolve this?
1. Keep mine (ours)
2. Keep theirs
3. Open the file in my editor — I'll resolve manually
4. Abort the rebase entirely
```

Wait for the user's choice:
- Choice 1: replace the conflict block with the `ours` lines.
- Choice 2: replace with `theirs` lines.
- Choice 3: print the file path and wait — tell the user to save the file and reply "done" when ready.
- Choice 4: run `git rebase --abort` and stop. Report: "Rebase aborted. Branch restored to its previous state."

c. After resolving all blocks in the file, run `git add <file>`.

d. If all auto-resolved: briefly report what was auto-resolved (e.g. "Auto-resolved 2 whitespace conflicts in foo.py").

After all conflicted files are handled, run `git rebase --continue`.

If `git rebase --continue` exits non-zero (more conflicts), loop back and repeat step 5.

### 6. Summary

Print:

```
Rebase complete.
  Branch:   <current branch>
  Onto:     <base>
  Commits replayed: N
  Conflicts resolved: X auto, Y by hand
```

If a stash was created in step 2, run `git stash pop` and report: "Unstashed your working tree changes."

## Rules

- **Never push.** Updating the remote is always the user's choice.
- **Never force-push.** Not even if the user asks within this skill — tell them to run `git push --force-with-lease` themselves.
- **Never squash or reword commits.** This skill is rebase-only, not interactive rebase.
- **Never modify `.gitconfig`, hooks, or shared config.**
- **Abort cleanly on user request.** Always offer `git rebase --abort` as an escape hatch.
- **Auto-resolve conservatively.** When in doubt, escalate — a false prompt is far less harmful than a wrong resolution.

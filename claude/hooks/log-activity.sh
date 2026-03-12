#!/usr/bin/env bash
# Claude Code hook — logs tool activity to ~/.claude/activity.log
# Logs all sessions; uses CLAUDE_AGENT name or "claude" as default.

set -uo pipefail

# ── Resolve agent name ────────────────────────────────────────────────────────
agent="${CLAUDE_AGENT:-}"
[[ -z "$agent" && -f ~/.claude/agent ]] && agent=$(cat ~/.claude/agent)
[[ -z "$agent" ]] && agent="claude"

# ── Guard: jq required ───────────────────────────────────────────────────────
command -v jq &>/dev/null || exit 0

# ── Read hook JSON from stdin ────────────────────────────────────────────────
input=$(cat)
[[ -z "$input" ]] && exit 0

# ── Extract fields ───────────────────────────────────────────────────────────
event=$(echo "$input" | jq -r '.hook_event_name // empty')
tool=$(echo "$input" | jq -r '.tool_name // empty')
project=$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")

# ── Build detail string ──────────────────────────────────────────────────────
detail=""

case "$event" in
SessionStart)
  detail="▶ session started"
  ;;
SubagentStart)
  detail="↳ subagent spawned"
  ;;
SubagentStop)
  detail="↲ subagent done"
  ;;
*)
  case "$tool" in
  Bash)
    cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
    detail="$ ${cmd:0:80}"
    ;;
  Edit | Write | Read)
    file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
    # Shorten home prefix for readability
    file="${file#$HOME/}"
    detail="$tool $file"
    ;;
  Grep)
    pattern=$(echo "$input" | jq -r '.tool_input.pattern // empty')
    detail="Grep \"$pattern\""
    ;;
  Glob)
    pattern=$(echo "$input" | jq -r '.tool_input.pattern // empty')
    detail="Glob $pattern"
    ;;
  Agent)
    desc=$(echo "$input" | jq -r '.tool_input.description // empty')
    detail="Agent: $desc"
    ;;
  Skill)
    skill=$(echo "$input" | jq -r '.tool_input.skill // empty')
    args=$(echo "$input" | jq -r '.tool_input.args // empty')
    detail="Skill: $skill${args:+ \"${args:0:60}\"}"
    ;;
  "")
    exit 0
    ;;
  *)
    detail="$tool"
    ;;
  esac
  ;;
esac

[[ -z "$detail" ]] && exit 0

# ── Append to activity log ───────────────────────────────────────────────────
mkdir -p ~/.claude
printf "[%s] %s | %s | %s\n" "$(date +%H:%M)" "$agent" "$project" "$detail" >>~/.claude/activity.log

#!/usr/bin/env bash
# Claude Code hook — logs tool activity to ~/.claude/activity.log
# Only logs when CLAUDE_AGENT is set (i.e., during work-as sessions).

set -uo pipefail

# ── Guard: only log during work-as sessions ──────────────────────────────────
agent="${CLAUDE_AGENT:-}"
[[ -z "$agent" && -f ~/.claude/agent ]] && agent=$(cat ~/.claude/agent)
[[ -z "$agent" ]] && exit 0

# ── Guard: jq required ───────────────────────────────────────────────────────
command -v jq &>/dev/null || exit 0

# ── Read hook JSON from stdin ────────────────────────────────────────────────
input=$(cat)
[[ -z "$input" ]] && exit 0

# ── Extract fields ───────────────────────────────────────────────────────────
event=$(echo "$input" | jq -r '.event // empty')
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
            Edit|Write|Read)
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
printf "[%s] %s | %s | %s\n" "$(date +%H:%M)" "$agent" "$project" "$detail" >> ~/.claude/activity.log

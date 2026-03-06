# Launch Claude Code as a named agent — work-as alpha, work-as beta, etc.
work-as() {
  local name="${1:-anon}"
  shift 2>/dev/null || true
  export CLAUDE_AGENT="$name"
  printf '%s' "$name" > ~/.claude/agent
  claude "$@"
  rm -f ~/.claude/agent
  unset CLAUDE_AGENT
}

# Colorize activity log lines by agent name
_color_agents() {
  awk -F'|' '
    BEGIN { n=0; split("31,32,33,34,35,36,91,92,93,94,95,96", colors, ",") }
    {
      agent = $1; sub(/^\[.*\] */, "", agent); gsub(/^ +| +$/, "", agent)
      if (map[agent] == "") { map[agent] = colors[(n++ % 12) + 1] }
      printf "\033[%sm%s\033[0m\n", map[agent], $0
      fflush()
    }
  '
}

# Watch all agents
watch-agents() {
  touch ~/.claude/activity.log
  tail -f ~/.claude/activity.log | _color_agents
}

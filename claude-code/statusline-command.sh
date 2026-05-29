#!/usr/bin/env bash
# Claude Code status line — Codex-style format

input=$(cat)

IFS=$'\t' read -r cwd model effort ctx_pct fh_used wd_used < <(
  jq -r '[
    .workspace.current_dir // .cwd // "",
    .model.display_name // "",
    .effort.level // "",
    .context_window.used_percentage // "",
    .rate_limits.five_hour.used_percentage // "",
    .rate_limits.seven_day.used_percentage // ""
  ] | @tsv' <<<"$input"
)

# Project name: basename of cwd
project=$(basename "${cwd:-$(pwd)}")

# Git branch
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" symbolic-ref --short HEAD 2>/dev/null \
  || GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" rev-parse --short HEAD 2>/dev/null)

# Remaining percentages
fh_rem=""
wd_rem=""
if [ -n "$fh_used" ]; then
  fh_rem=$(awk "BEGIN {printf \"%.0f\", 100 - $fh_used}")
fi
if [ -n "$wd_used" ]; then
  wd_rem=$(awk "BEGIN {printf \"%.0f\", 100 - $wd_used}")
fi

SEP=" · "

printf "%s" "$project"
[ -n "$branch" ]  && printf "%s%s" "$SEP" "$branch"
[ -n "$model" ]   && printf "%s%s" "$SEP" "$model${effort:+ $effort}"
[ -n "$ctx_pct" ] && printf "%sContext %s%% used" "$SEP" "$(printf '%.0f' "$ctx_pct")"
[ -n "$fh_rem" ]  && printf "%s5h %s%%" "$SEP" "$fh_rem"
[ -n "$wd_rem" ]  && printf "%sweekly %s%%" "$SEP" "$wd_rem"

printf "\n"

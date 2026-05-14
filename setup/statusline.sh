#!/usr/bin/env bash

input=$(cat)

JQ="/c/Users/tiago/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe/jq.exe"

model=$("$JQ" -r '.model.display_name // "Unknown"' <<< "$input")
ctx_used=$("$JQ" -r '.context_window.used_percentage // empty' <<< "$input")
rate_used=$("$JQ" -r '.rate_limits.five_hour.used_percentage // empty' <<< "$input")
rate_reset=$("$JQ" -r '.rate_limits.five_hour.resets_at // empty' <<< "$input")
transcript=$("$JQ" -r '.transcript_path // empty' <<< "$input")

# Count conversation turns (user messages) from transcript
turns=0
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  turns=$("$JQ" -r '[.[] | select(.type == "user")] | length' "$transcript" 2>/dev/null || echo 0)
fi

# ANSI color codes
CYAN='\033[0;36m'
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
DIM='\033[2m'
RESET='\033[0m'

# Build model segment with color
model_seg="${CYAN}${BOLD}${model}${RESET}"

# Build a 10-block progress bar
# $1 = percentage (integer 0-100), $2 = color for filled blocks
make_bar() {
  local pct=$1
  local color=$2
  local filled=$(( pct * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  local empty=$(( 10 - filled ))
  local bar="${color}"
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  bar="${bar}${RESET}${DIM}"
  for ((i=0; i<empty; i++)); do bar="${bar}░"; done
  bar="${bar}${RESET}"
  printf "%b" "$bar"
}

# Pick color for context bar based on usage
ctx_bar_color="$GREEN"
if [ -n "$ctx_used" ]; then
  ctx_pct=$("$JQ" -r 'def round: . + 0.5 | floor; .context_window.used_percentage | round' <<< "$input")
  [ "$ctx_pct" -ge 75 ] && ctx_bar_color="$YELLOW"
  [ "$ctx_pct" -ge 90 ] && ctx_bar_color="$RED"
fi

# Pick color for rate-limit bar based on usage
rate_bar_color="$GREEN"
if [ -n "$rate_used" ]; then
  rate_pct=$("$JQ" -r 'def round: . + 0.5 | floor; .rate_limits.five_hour.used_percentage | round' <<< "$input")
  [ "$rate_pct" -ge 75 ] && rate_bar_color="$YELLOW"
  [ "$rate_pct" -ge 90 ] && rate_bar_color="$RED"
fi

# --- Assemble output ---

# Turns segment
turns_seg=""
[ "$turns" -gt 0 ] && turns_seg="${DIM}${turns}t${RESET}"

# Context window segment
ctx_seg=""
if [ -n "$ctx_used" ]; then
  ctx_bar=$(make_bar "$ctx_pct" "$ctx_bar_color")
  ctx_seg="${ctx_bar_color}ctx${RESET} [${ctx_bar}] ${ctx_bar_color}${ctx_pct}%${RESET}"
fi

# Daily (5-hour) rate limit segment
rate_seg=""
if [ -n "$rate_used" ]; then
  rate_bar=$(make_bar "$rate_pct" "$rate_bar_color")
  # Build countdown to reset
  countdown=""
  if [ -n "$rate_reset" ]; then
    now=$(date +%s)
    reset_epoch="$rate_reset"
    if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now" ] 2>/dev/null; then
      diff=$(( reset_epoch - now ))
      h=$(( diff / 3600 ))
      m=$(( (diff % 3600) / 60 ))
      countdown=" ${DIM}reset ${h}h${m}m${RESET}"
    fi
  fi
  rate_seg="${rate_bar_color}5h${RESET} [${rate_bar}] ${rate_bar_color}${rate_pct}%${RESET}${countdown}"
fi

# Join non-empty segments with " | "
parts=()
[ -n "$turns_seg" ] && parts+=("$turns_seg")
parts+=("$model_seg")
[ -n "$rate_seg"  ] && parts+=("$rate_seg")
[ -n "$ctx_seg"   ] && parts+=("$ctx_seg")

output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="${output}${DIM} | ${RESET}${part}"
  fi
done

printf "%b" "$output"

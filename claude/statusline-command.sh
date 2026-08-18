#!/bin/sh
input=$(cat)

# single jq call: parses, floor-truncates percentages, and computes the
# ctx>80 flag all at once instead of forking jq/awk a dozen times per render
# unit separator, not tab: `read` collapses consecutive tabs as IFS whitespace and drops empty fields
SEP=$(printf '\037')
fields=$(echo "$input" | jq -r '
  .cwd as $cwd |
  (.model.display_name // "?") as $model |
  (.effort.level // "") as $effort |
  (.thinking.enabled // false) as $thinking |
  .context_window.used_percentage as $ctx |
  .rate_limits.five_hour.used_percentage as $fhp |
  .rate_limits.five_hour.resets_at as $fhr |
  .rate_limits.seven_day.used_percentage as $sdp |
  .rate_limits.seven_day.resets_at as $sdr |
  [
    $cwd, $model, $effort, $thinking,
    (if $ctx == null then "" else ($ctx | floor | tostring) end),
    (if $ctx == null then "" elif $ctx > 80 then "1" else "0" end),
    (if $fhp == null then "" else ($fhp | floor | tostring) end),
    (if $fhr == null then "" else ($fhr | tostring) end),
    (if $sdp == null then "" else ($sdp | floor | tostring) end),
    (if $sdr == null then "" else ($sdr | tostring) end)
  ] | join("")
')
IFS="$SEP" read -r cwd model effort thinking ctx_pct ctx_over80 fh_pct fh_reset sd_pct sd_reset <<EOF
$fields
EOF

# one date call instead of two; split epoch/formatted via parameter expansion
datetime=$(date -u '+%s %Y-%m-%d %H:%M:%S')
now=${datetime%% *}
now_str=${datetime#* }

# seconds -> "Xd Yh" or "Yh Zm" abbreviated (ponytail: cosmetic only)
fmt_duration() {
  secs=$1
  [ "$secs" -lt 0 ] && secs=0
  d=$((secs / 86400))
  h=$(((secs % 86400) / 3600))
  m=$(((secs % 3600) / 60))
  if [ "$d" -gt 0 ]; then
    printf '%dd %dh' "$d" "$h"
  else
    printf '%dh %dm' "$h" "$m"
  fi
}

# model, effort, thinking share one color (blue) as one logical group
thinking_word="thinking"
[ "$thinking" != "true" ] && thinking_word="\033[9mthinking\033[29m"
model_details="🤖 \033[94m${model}"
[ -n "$effort" ] && model_details="${model_details} ${effort}"
model_details="${model_details} ${thinking_word}\033[0m"

ctx_info=""
if [ -n "$ctx_pct" ]; then
  ctx_color="\033[92m"
  [ "$ctx_over80" = "1" ] && ctx_color="\033[91m"
  ctx_info=" ${ctx_color}💡 ${ctx_pct}%\033[0m"
fi

fh_info=""
if [ -n "$fh_pct" ] && [ -n "$fh_reset" ]; then
  fh_dur=$(fmt_duration $((fh_reset - now)))
  fh_info=" \033[90m5h: ${fh_pct}%, ${fh_dur}\033[0m"
fi

sd_info=""
if [ -n "$sd_pct" ] && [ -n "$sd_reset" ]; then
  sd_dur=$(fmt_duration $((sd_reset - now)))
  sd_info=" \033[90m7d: ${sd_pct}%, ${sd_dur}\033[0m"
fi

printf ' 📅 \033[96m%s UTC\033[0m 🤷 \033[92m%s\033[0m ⚙️ \033[93m%s\033[0m 🚀 \033[95m%s\033[0m 📊%b |%b %b%b' \
  "$now_str" \
  "${USER:-$(whoami)}" \
  "$(hostname -s)" \
  "$cwd" \
  "$fh_info" \
  "$sd_info" \
  "$model_details" \
  "$ctx_info"

#/usr/bin/bash

declare -Ar COLORS=(
    [RED]=$'\033[0;31m'
    [GREEN]=$'\033[0;32m'
    [BLUE]=$'\033[0;34m'
    [PURPLE]=$'\033[0;35m'
    [CYAN]=$'\033[0;36m'
    [WHITE]=$'\033[0;37m'
    [YELLOW]=$'\033[0;33m'
    [OFF]=$'\033[0m'
    [BOLD]=$'\033[1m'
)

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

function get_secrets {
  paths="$(get_tmux_option '@tmux_vault_paths' 'secret')"
  cache_enabled="$(get_tmux_option '@tmux_vault_cache_enabled' '1')"
  cache_path="$(get_tmux_option '@tmux_vault_cache_path' '/var/tmp/tmux_vault_cache')"
  cache_duration="$(get_tmux_option '@tmux_vault_cache_duration' '86400')"
  
  if (( "$cache_enabled" )); then # cache is enabled
    if [[ -r "$cache_path" ]]; then
      if (( "$(( $(date +"%s") - $(stat -c "%Y" $cache_path) ))" > "$cache_duration" )); then # cache has expired
        vkv -p $paths --only-paths > $cache_path
        printf "%s" "$(<$cache_path)"
      else # cache has not expired, return it
        printf "%s" "$(<$cache_path)"
      fi
    else # cache does not exist
      vkv -p $paths --only-paths > $cache_path
      printf "%s" "$(<$cache_path)"
    fi
  else # no cache requested
    printf "%s" "$(vkv -p $paths --only-paths)"
  fi
}

enter_key="enter"
selectall_key='ctrl-a'
deselectall_key='ctrl-d'
fzf_expect="$selectall_key,$deselectall_key,ctrl-c,esc,enter"
fzf_bind="$selectall_key:select-all,$deselectall_key:deselect-all"

header_tmpl="${COLORS[BOLD]}${selectall_key}${COLORS[OFF]}=select all"
header_tmpl+=", ${COLORS[BOLD]}${COLORS[ORANGE]}${deselectall_key}${COLORS[OFF]}=deselect all"
header_tmpl+=", ${COLORS[BOLD]}${COLORS[YELLOW]}tab${COLORS[OFF]}=select"
header_tmpl+=", ${COLORS[BOLD]}${COLORS[GREEN]}enter${COLORS[OFF]}=open browser"
header_tmpl+=", ${COLORS[BOLD]}${COLORS[RED]}ctrl-c|esc${COLORS[OFF]}=quit"
fzf_header=$header_tmpl

out=$(get_secrets | tee /tmp/stage1 |fzf-tmux \
            --ansi -i -1 --height=50% --reverse -0 --inline-info --border \
            --bind="${fzf_bind}" --no-info \
            --header="${fzf_header}" |tee /tmp/stage2)
            #--expect="${fzf_expect}" \

if [ ! -z "$out" ]; then
  # split mutliple line into array
  mapfile -t out <<< "$out"
  urls=""
  for url in "${out[@]}"; do
    url=${url%% *}/alerts
    printf -v urls -- ' %s --new-tab %s' "${urls}" "${url}" 
  done
  vault kv get $out
fi

#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

bind_key="$(get_tmux_option '@tmux_vault_bind_key' 'v')"

tmux bind-key "$bind_key" run-shell -b "$CURRENT_DIR/scripts/tmux_vault.sh"
#tmux bind-key "$key" run-shell -b "$CURRENT_DIR/scripts/tmux_vault.sh &> /tmp/tmux-vault.log"

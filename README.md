# tmux-vault

Tmux plugin for HashiCorp Vault.

Features:

* list all secrets you have access to
* support multiple paths ('kv' secret engine)
* display password 
* copy to buffer (todo)

## Pre-requisites

### vkv

[vkv](https://github.com/FalcoSuessgott/vkv) is used to recursively find all secrets a token has access to.

### fzf

fzf is used to display the secrets paths.

### vault

vault CLI is used to retrieve a secret.

## Configuration

### Environment variables

* `TMUX_VAULT_PATHS`: coma separated list of secret engine path (or sub-path)
* `VAULT_ADDR`: vault URL
* `VAULT_TOKEN`: vault token

```
export TMUX_VAULT_PATHS=secret,kv
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=token
```

If you set any of those environment variables after you load your `tmux` session, you might need to run:

```
tmux set-environment -g TMUX_VAULT_PATHS $TMUX_VAULT_PATHS
tmux set-environment -g VAULT_ADDR $VAULT_ADDR
tmux set-environment -g VAULT_TOKEN $VAULT_TOKEN
```

### Tmux configuration

To install the plugin:

```
set -g @plugin 'jertozzi/tmux-vault
```

Then press `<tmux-prefix>I`.

A default binding (`<tmux-prefix>-v`) is provided to display the secret list.

The default binding can be overwritten by setting in your `~/.tmux.conf`:

```
set -g @tmux_vault_bind_key 's'
```

In order to help with large vault instances with a lot of secrets, the secret paths (not the content!) may be kept in cache by setting the following variables:

```
set -g @tmux_vault_cache_enabled '1' # enable path cache
set -g @tmux_vault_cache_duration '86400' # cache expiration in seconds
set -g @tmux_vault_cache_path '/var/tmp/tmux_vault_cache' # path cache location
```

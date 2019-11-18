#!/run/current-system/sw/bin/env nix-shell
#!nix-shell -i bash -p jq nixops vulnix awscli -I channel:nixos-unstable
log () {
    echo "[$(date "+%FT%T")] $1"
}

error_exit () {
    log "ERROR: $1"
    exit 1
}

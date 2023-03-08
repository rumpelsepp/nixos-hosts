#!/usr/bin/env bash

set -eu

restic_args=(
	--verbose
	--one-file-system
	--exclude-caches
	--exclude "$HOME/go"
	--exclude "$HOME/.npm"
	--exclude "$HOME/.cargo"
	--exclude "$HOME/.cache"
	--exclude "$HOME/.mozilla"
	--exclude "$HOME/.cargo/registry"
	--exclude "$HOME/.config/Code/Cache*"
	--exclude "$HOME/.config/Code/User"
	--exclude "$HOME/.config/chromium"
	--exclude "$HOME/.config/syncthing"
	--exclude "$HOME/.mozilla"
	--exclude "$HOME/.local/share"
	--exclude "$HOME/.var"
	--exclude "$HOME/.venvs"
	--exclude "$HOME/.rustup"
	--exclude "$HOME/fuse"
	--exclude "*.so"
	--exclude "*.whl"
	--exclude '*.o'
	--exclude '*.ko'
	--exclude '*.rlib'
	--exclude '*.lldb'
	"$HOME"
)

# restic check
restic-wrapper.sh backup "${restic_args[@]}"

#!/usr/bin/env bash
# Bootstrap dotfiles on a fresh machine.
# Usage:  bash <(curl -fsSL https://raw.githubusercontent.com/DeltaVector1/dotfiles/master/install.sh)

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/DeltaVector1/dotfiles.git}"
TARBALL_URL="${TARBALL_URL:-https://github.com/DeltaVector1/dotfiles/archive/refs/heads/master.tar.gz}"
BRANCH="${BRANCH:-master}"

# stdin must be a tty for prompts. When piped (curl ... | bash), reopen /dev/tty.
if [ ! -t 0 ]; then
  exec </dev/tty
fi

lc() { tr '[:upper:]' '[:lower:]'; }

ask_yn() {
  local prompt="$1" default="${2:-N}" reply
  printf "%s [y/N] " "$prompt" >&2
  IFS= read -r reply || reply=""
  reply="${reply:-$default}"
  case "$(printf "%s" "$reply" | lc)" in
    y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

ask_choice() {
  local prompt="$1"; shift
  local options="$*"
  local reply opt match
  while :; do
    printf "%s [%s] " "$prompt" "${options// /\/}" >&2
    IFS= read -r reply || reply=""
    reply="$(printf "%s" "$reply" | lc)"
    match=""
    for opt in $options; do
      if [ "$reply" = "$(printf "%s" "$opt" | lc)" ]; then
        match="$opt"
        break
      fi
    done
    if [ -n "$match" ]; then
      printf "%s" "$match"
      return
    fi
    printf "  please pick one of: %s\n" "$options" >&2
  done
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
src="$tmp/dotfiles"

echo "[*] fetching dotfiles"
if command -v git >/dev/null 2>&1; then
  git clone --quiet --depth=1 -b "$BRANCH" "$REPO_URL" "$src"
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL "$TARBALL_URL" | tar -xz -C "$tmp"
  mv "$tmp/dotfiles-$BRANCH" "$src"
else
  echo "need git or curl on PATH" >&2
  exit 1
fi

agent="$(ask_choice "Which agent are you using?" claude codex both skip)"
if [ "$agent" != "skip" ]; then
  dest="$(pwd)"
  echo "[*] dropping agent bundle into $dest"
  case "$agent" in
    claude)
      cp "$src/agents/CLAUDE.md" "$dest/"
      mkdir -p "$dest/.claude/commands"
      cp -R "$src/agents/.claude/commands/." "$dest/.claude/commands/"
      ;;
    codex)
      cp "$src/agents/AGENTS.md" "$dest/"
      mkdir -p "$dest/.agents/skills"
      cp -R "$src/agents/.agents/skills/." "$dest/.agents/skills/"
      ;;
    both)
      cp "$src/agents/CLAUDE.md" "$src/agents/AGENTS.md" "$dest/"
      mkdir -p "$dest/.claude/commands" "$dest/.agents/skills"
      cp -R "$src/agents/.claude/commands/." "$dest/.claude/commands/"
      cp -R "$src/agents/.agents/skills/." "$dest/.agents/skills/"
      ;;
  esac
fi

backup() {
  local f="$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    cp -R "$f" "$f.bak.$(date +%s)"
  fi
}

if ask_yn "Install nvim config to ~/.config/nvim?"; then
  mkdir -p "$HOME/.config"
  backup "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim"
  cp -R "$src/nvim" "$HOME/.config/nvim"
  echo "[+] nvim installed"
fi

if ask_yn "Replace ~/.bashrc?"; then
  backup "$HOME/.bashrc"
  cp "$src/.bashrc" "$HOME/.bashrc"
  echo "[+] .bashrc installed"
fi

if ask_yn "Replace ~/.gitconfig?"; then
  backup "$HOME/.gitconfig"
  cp "$src/.gitconfig" "$HOME/.gitconfig"
  echo "[+] .gitconfig installed"
fi

# Astral uv — installed unconditionally, skipped if already present.
if command -v uv >/dev/null 2>&1; then
  echo "[=] uv already installed ($(uv --version))"
else
  echo "[*] installing astral uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Make uv available for any later steps in this same script run.
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env" || true

echo ""
echo "[*] done."
echo ""
echo "    A subshell can't refresh your parent terminal. To pick up uv now:"
echo "      exec \$SHELL -l        # replaces current shell with a fresh login shell"
echo "    or just open a new terminal."

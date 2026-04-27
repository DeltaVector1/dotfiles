# Only run for interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

# Make user-local binaries (uv, cargo, pipx, etc.) available without relying on
# tool-specific source lines that get clobbered when this file is replaced.
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"
export PATH

# Forgiving cd: minor typos and case-insensitive directory matches.
shopt -s cdspell autocd 2>/dev/null

# `cd ass` -> `cd Ass` when the literal arg doesn't match.
cd() {
  if (($# == 0)) || [[ $1 == -* ]]; then
    builtin cd "$@"
    return
  fi
  if builtin cd "$@" 2>/dev/null; then
    return
  fi
  local match
  match=$(find . -maxdepth 1 -type d -iname "$1" 2>/dev/null | head -n1)
  if [[ -n $match ]]; then
    builtin cd "$match"
  else
    builtin cd "$@"
  fi
}

# Case-insensitive tab completion for paths.
bind 'set completion-ignore-case on' 2>/dev/null

alias clod='claude --dangerously-skip-permissions'

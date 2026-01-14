# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac
export OSH='/home/dgxuser/.oh-my-bash'
OSH_THEME="simple"
alias clod='claude --dangerously-skip-permissions'
# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"
OMB_USE_SUDO=true

completions=(
  git
  composer
  ssh
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
)





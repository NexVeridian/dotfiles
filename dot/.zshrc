# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/elijahmcmorris/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

bindkey -v
bindkey '^R' history-incremental-search-backward

export EDITOR="zed --wait"
export VISUAL="zed --wait"

# alias make=just
alias npm=pnpm
alias npx="pnpm dlx"

alias cat="bat --paging=never"
alias ls="eza"
alias tree="eza -T"
eval "$(zoxide init zsh)"
alias cd="z"
alias du="dua i"

alias lg="lazygit"
alias ld="lazydocker"
alias jg="jjui"
export JJUI_CONFIG_DIR="~/.config/jjui/config.toml"

alias k=kubectl
# alias cargo="RUSTFLAGS='-Z threads=16' cargo"
# alias cargo="CARGO_PROFILE_DEV_CODEGEN_BACKEND=cranelift cargo -Zcodegen-backend"

export PATH=$PATH:/Users/elijahmcmorris/.cargo/bin

cargo install-update -a

export DYLD_LIBRARY_PATH="$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH"


# lazydocker: https://github.com/jesseduffield/lazydocker/issues/4#issuecomment-2594808943
# export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')

# railpack
# export BUILDKIT_HOST=docker-container://buildkit

# colima: https://github.com/abiosoft/colima/issues/365#issuecomment-1953318849
# export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"

# https://stackoverflow.com/a/76586216/8179347
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# https://huggingface.co/docs/datasets/en/cache
# export HF_HUB_CACHE="/Volumes/hf-cache/huggingface/hub"
# export HF_DATASETS_CACHE="/Volumes/hf-cache/huggingface/datasets"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/elijahmcmorris/.cache/lm-studio/bin"

# pnpm
export PNPM_HOME="/Users/elijahmcmorris/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# export CONTROL_PLANE_IP=("5.78.158.51" "5.78.93.199" "5.78.92.203")
# export CONTROL_PLANE_IP=("5.78.158.51")
# export WORKER_IP=("5.78.158.51")
# export CLUSTER_NAME=nex
# export KUBECONFIG="./kubeconfig"

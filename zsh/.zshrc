export ZSH="$HOME/.oh-my-zsh"

# robbyrussell loads OMZ git prompt machinery; PROMPT below prepends our custom line to it
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

PROMPT=' 📅 %F{12}$(TZ=UTC date "+%Y-%m-%d %H:%M:%S UTC")%f 🤷 %F{green}%n%f ⚙️ %F{yellow}%m%f 🗂️ %{$fg[cyan]%}%~%{$reset_color%}
'"$PROMPT"

export PATH="$HOME/.local/bin:$PATH"

if (( $+commands[brew] )); then
    eval "$(brew shellenv)"
fi

if (( $+commands[chruby] )); then
    source $HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh
    source $HOMEBREW_PREFIX/opt/chruby/share/chruby/auto.sh
fi

if (( $+commands[flux] )); then
    . <(flux completion zsh)
fi

[ -f /etc/rancher/k3s/k3s.yaml ] && export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

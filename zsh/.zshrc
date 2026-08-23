export ZSH="$HOME/.oh-my-zsh"

# robbyrussell loads OMZ git prompt machinery; PROMPT below prepends our custom line to it
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

HOST_SEGMENTS=(${(s:.:)HOST})
PROMPT=' 📅 %F{12}$(TZ=UTC date "+%Y-%m-%d %H:%M:%S UTC")%f 🤷 %F{green}%n%f ⚙️ %F{yellow}${(j:.:)HOST_SEGMENTS[1,3]}%f 🗂️ %{$fg[cyan]%}%~%{$reset_color%}
'"$PROMPT"

if [ -f "$HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh" ]; then
    source "$HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh"
    source "$HOMEBREW_PREFIX/opt/chruby/share/chruby/auto.sh"
fi

if (( $+commands[flux] )); then
    _flux_comp="${XDG_CACHE_HOME:-$HOME/.cache}/flux_completion.zsh"
    [[ -f "$_flux_comp" ]] || { mkdir -p "${_flux_comp:h}" && flux completion zsh >| "$_flux_comp" }
    source "$_flux_comp"
    unset _flux_comp
fi

[ -f /etc/rancher/k3s/k3s.yaml ] && export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

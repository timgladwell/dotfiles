# Homebrew — handles both Apple Silicon (/opt/homebrew) and Intel (/usr/local)
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$_brew" ] && eval "$($_brew shellenv)" && break
done
unset _brew

export PATH="$HOME/.local/bin:$PATH"

# Go workspace binaries — requires go in PATH (set above via brew)
if (( $+commands[go] )); then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

# Homebrew — handles both Apple Silicon (/opt/homebrew) and Intel (/usr/local)
# Runs the first brew found; `brew shellenv` adds it to PATH (Apple Silicon's
# /opt/homebrew isn't on it by default) and exports HOMEBREW_PREFIX, which .zshrc
# uses. Finding neither (servers) is a silent no-op.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$_brew" ] && eval "$($_brew shellenv)" && break
done
unset _brew
# Cap source builds at 4 parallel jobs so the 6-core Intel MacBook stays usable.
export HOMEBREW_MAKE_JOBS=4

export PATH="$HOME/.local/bin:$PATH"

# Go workspace binaries — requires go in PATH (set above via brew)
if (( $+commands[go] )); then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

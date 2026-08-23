#!/usr/bin/env zsh

alias ls='ls -lah --color=auto'

# --- git ---------------------------------------------------------------------
# Interactive-only: kept out of ~/.gitconfig so scripts parsing `git log --oneline`
# aren't broken by injected signature lines.

# log: signature status + files changed (overrides oh-my-zsh's plain --stat glg)
alias glg='git log --show-signature --stat'
alias glgp='git log --show-signature --stat --patch'

# Re-sign the unsigned commits at the tip. Same call on main or a feature branch:
# it counts back to the first signed commit rather than rebasing onto a base branch.
# One YubiKey touch per commit, and no prompt is shown for it.
resign() {
	# Never rewrite commits that are already pushed.
	local max=50
	git rev-parse --abbrev-ref @{u} >/dev/null 2>&1 && max=$(git rev-list --count @{u}..HEAD)

	# Depth of the OLDEST unsigned commit: they aren't always contiguous at the tip
	# (amending the tip leaves older unsigned commits stranded underneath).
	local n=0 depth=0
	while [ "$n" -lt "$max" ]; do
		[ "$(git log -1 --format='%G?' "HEAD~$n" 2>/dev/null)" = "N" ] && depth=$((n + 1))
		n=$((n + 1))
	done

	if [ "$depth" -eq 0 ]; then
		echo "Nothing to re-sign (all unpushed commits are signed)."
		return 0
	fi
	echo "Re-signing $depth commit(s) — all of these are rewritten with new hashes:"
	git --no-pager log --oneline --no-show-signature "HEAD~$depth..HEAD"
	echo "Touch the YubiKey once per commit — no prompt is shown, and it times out."
	echo "If a touch is missed, the rebase stops: run 'git rebase --abort' and retry."
	# -f forces replay, -S signs each replayed commit: one touch per commit, not two.
	git rebase -f -S "HEAD~$depth"
}

#!/usr/bin/env zsh

alias ls='ls -lah --color=auto'

# --- git ---------------------------------------------------------------------
# Interactive-only: kept out of ~/.gitconfig so scripts parsing `git log --oneline`
# aren't broken by injected signature lines.

# log: signature status + files changed (overrides oh-my-zsh's plain --stat glg)
alias glg='git log --show-signature --stat'
alias glgp='git log --show-signature --stat --patch'

# Re-sign the unsigned commits at the tip. Same call on main or a feature branch.
# On a feature branch it scans the whole branch (back to the base branch), so it
# also re-signs commits an agent already pushed — those need `git push --force-with-lease`
# afterwards. On the base branch itself it only touches unpushed commits.
# One YubiKey touch per commit, and no prompt is shown for it.
resign() {
	local base branch max
	base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
	# origin/HEAD isn't always set locally; fall back to the usual names.
	[ -z "$base" ] && for b in origin/main origin/master; do
		git rev-parse --verify --quiet "$b" >/dev/null && base=$b && break
	done
	branch=$(git rev-parse --abbrev-ref HEAD)

	if [ -n "$base" ] && [ "$branch" != "${base#origin/}" ]; then
		# Feature branch: everything since it forked off the base branch is fair game.
		max=$(git rev-list --count "$base..HEAD")
	elif git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
		max=$(git rev-list --count @{u}..HEAD)   # on the base branch: unpushed only
	else
		max=50
	fi

	# Depth of the OLDEST unsigned commit: they aren't always contiguous at the tip
	# (amending the tip leaves older unsigned commits stranded underneath).
	local n=0 depth=0
	while [ "$n" -lt "$max" ]; do
		[ "$(git log -1 --format='%G?' "HEAD~$n" 2>/dev/null)" = "N" ] && depth=$((n + 1))
		n=$((n + 1))
	done

	if [ "$depth" -eq 0 ]; then
		echo "Nothing to re-sign."
		return 0
	fi
	echo "Re-signing $depth commit(s) — all of these are rewritten with new hashes:"
	git --no-pager log --oneline --no-show-signature "HEAD~$depth..HEAD"
	echo "Touch the YubiKey once per commit — no prompt is shown, and it times out."
	echo "If a touch is missed, the rebase stops: run 'git rebase --abort' and retry."
	# -f forces replay, -S signs each replayed commit: one touch per commit, not two.
	git rebase -f -S "HEAD~$depth" || return

	# Already-pushed commits were rewritten, so the remote branch needs replacing.
	if [ "$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)" -gt 0 ]; then
		echo "Remote has the old commits — push with: git push --force-with-lease"
	fi
}

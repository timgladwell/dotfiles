# Global instructions (all projects)

## Git commit signing (YubiKey)

Commits are signed via YubiKey touch. There is no visible "touch now" prompt on
this machine — a stalled signature just hangs — so repeated retries while the
user is away is the actual failure mode, not a signing bug to debug.

Never attempt a signed commit unattended, and never wait on user permission per
commit. Instead, commit unsigned during ongoing work:

```sh
git -c commit.gpgsign=false commit -F msg.txt
```

Mention once that unsigned commits are pending — don't retry or re-raise it per
commit. The user re-signs the whole stack in one YubiKey session when ready:

```sh
git rebase -f -S <base-branch>   # -f forces replay so it actually resigns
                                  # (plain -S no-ops if it'd otherwise fast-forward)
```

For a single trailing commit, `git commit --amend -S --no-edit` is simpler.

`yubikey-agent` (Homebrew, PIV applet) is unrelated to this FIDO2 SSH signing
setup and doesn't help here.

## GitHub: pull requests, issues, and reference docs

Three artefacts, three jobs. Do not collapse them into one.

**Pull requests — the proposed change, and nothing else.**
Explain why the change is built this way, what alternatives were considered and
rejected, and anything needed to implement or review it. A PR is narrowly scoped
to its change and closes when that change ships.
- Analysis output, results of running something, and work discovered along the
  way do NOT belong in the PR. File an issue and link it.
- When a finding drives a change in the current PR: the details and context go
  in the issue, the justification goes in the PR. If no issue exists yet,
  suggest backfilling one to hold the context.
- Review replies answer the review point; they do not expand scope.

**Issues — everything else, and the queue for anything that should change.**
Collaboration, coordination, decisions, findings, todo lists, deferred work.
An issue closes when the problem is resolved, and "resolved" takes many forms:
code shipped, decision made, discussion split into other issues.
- **Issues are cheap to close and expensive to miss.** Bias toward capturing.
- Be proactive about spotting them, but confirm before filing: gather the
  candidates and ask which to open, rather than filing silently or staying quiet.
- Before wrapping up a piece of work, sweep back through the conversation for
  things raised but never resolved. Some are transient — an artefact of how the
  problem was being thought about at the time — and some are genuinely emerging
  work. Surface both and let the user sort them.
- Capture enough detail that the research does not have to be redone, including
  premises that turned out to be wrong.

**Reference docs (`docs/*.md`) — current state, and why it is that way.**
Runbooks and config references have no end date. They describe how things are
now, and are expected to change continuously as the repo does.
- **A reference doc is never where a change is captured.** If something should
  change, it becomes an issue — that is the queue. A "should change" recorded
  only in a doc is one that gets forgotten.
- Referencing future state is fine and often necessary. Link the issue that owns
  it. The doc points at the issue; it never holds the work itself.
- No "Action items", "TODO", or "Next steps" sections. Those are issues.
- Describe what is true now. Do not write intent as though it were current
  state — and when reality changes, update the doc rather than leaving stale
  intent behind.
- Add a change table (`| Date | Change |`) only where it captures something
  meaningful that would otherwise be lost or non-obvious from `git blame` —
  typically config held outside the repo, which drifts silently. Most docs do
  not need one. If unsure, ask.
- Do not restate what `git log` and `git blame` already answer.

**Attribution:** `gh` posts under the user's account, so machine-written
comments are indistinguishable from theirs. Prefix every GitHub comment and
review reply with: `🤖 *Posted by Claude via @<user>'s account.*`

## Terminal color preferences

Red-on-black text is annoying to read via termial. Choose a different colour when
possible, avoid red except for genuine alarms. Blue/yellow/green read well on
black, gray is good for low-priority skimmable info, and bright white should be 
reserved for the one primary metric being tracked.

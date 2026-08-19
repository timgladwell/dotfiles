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

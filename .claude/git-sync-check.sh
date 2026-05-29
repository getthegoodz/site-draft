#!/usr/bin/env bash
# SessionStart guard for the multi-machine site-draft workflow.
# This repo is edited from several clones (Mike's machine, the Mac Mini's
# Claude instances, Louisa via the Telegram bot), all pushing under the same
# identity. Git only protects the REMOTE (it rejects non-fast-forward pushes);
# it does nothing to stop a clone from editing stale files or to protect
# uncommitted work from being clobbered by a pull. This hook closes that gap
# by fetching and warning at the start of a session, before any editing.
#
# Best-effort by design: it must NEVER block or fail a session. Always exit 0.

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}" 2>/dev/null || exit 0

# Only act inside a git repo that has an origin.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0

# Make diverged pulls refuse to auto-merge, so a stale pull can't silently
# create a merge commit or drop work. Per-clone config; idempotent, so running
# it every session also propagates the setting to every machine.
git config pull.ff only

# direnv isn't hooked in a non-interactive hook shell; load it so GH_TOKEN is
# present for fetching a private repo. Harmless if direnv isn't installed.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv export bash 2>/dev/null)" 2>/dev/null
fi

git fetch --quiet origin 2>/dev/null || { echo "git-sync: fetch skipped (no network or auth)."; exit 0; }

branch=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0
upstream="origin/${branch}"
git rev-parse --verify "$upstream" >/dev/null 2>&1 || exit 0

behind=$(git rev-list --count "HEAD..$upstream" 2>/dev/null)
ahead=$(git rev-list --count "$upstream..HEAD" 2>/dev/null)

if [ "${behind:-0}" -gt 0 ]; then
  echo "WARNING  git-sync: '$branch' is $behind commit(s) BEHIND $upstream (and ${ahead:-0} ahead)."
  echo "    Another clone pushed work you don't have. Before editing:"
  echo "      1. Commit or stash any local changes (a pull can clobber uncommitted work)."
  echo "      2. git pull --rebase   (pull.ff=only is set, so a diverged pull won't auto-merge)."
else
  echo "git-sync: '$branch' is up to date with $upstream (${ahead:-0} ahead)."
fi
exit 0

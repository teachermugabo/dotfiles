# Dotfiles TODO

## Config tasks

- [ ] Install Hammerspoon (`brew install hammerspoon`) — configured but app not installed
- [ ] Decide on fish as default shell or remove from active config
- [x] ~~Sync with upstream~~ — **Decision (2026-04-30):** don't rebase/merge upstream wholesale. `mine` has diverged enough to be its own config. Keep `upstream` remote for browsing (`git fetch upstream`) and cherry-pick selectively if something interesting comes up. Never `git merge upstream/main`.

## Future ideas

- [ ] Consider moving personal knowledge base (plans, skills, reading-list, learnings) out of `~/.claude/` into a dedicated portable directory

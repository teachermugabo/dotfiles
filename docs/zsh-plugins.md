# Zsh Plugins Guide

Your oh-my-zsh setup includes plugins that enhance shell productivity. Here's what each does and how to use them.

## Core Plugins (Installed)

### `git`
**What it does:** Provides convenient aliases for common git commands.

**Common aliases:**
- `ga` → `git add`
- `gc` → `git commit`
- `gco` → `git checkout`
- `gp` → `git push`
- `gpl` → `git pull`
- `gd` → `git diff`
- `gst` → `git status`
- `gb` → `git branch`

For the full list, run: `alias | grep "^g"`

---

### `fzf`
**What it does:** Integrates fzf fuzzy finder into your shell for:
- `Ctrl+R` — fuzzy search command history
- `Ctrl+T` — fuzzy file picker (inserts file path)
- `Alt+C` — fuzzy directory navigator

**How to use:**
```bash
# Fuzzy find a file and open it
vim $(fzf)

# Search history interactively
Ctrl+R

# Jump to a directory
Alt+C
```

**Pro tip:** Combine with `fzf-git.sh` for `gh` (fuzzy git checkout) — see notes below.

---

### `zsh-autosuggestions`
**What it does:** Shows command suggestions as you type, based on your history.

**How to use:**
- Start typing a command you've used before
- Press `→` (right arrow) or `End` to accept the suggestion
- Press `Ctrl+Space` to accept word-by-word

**Example:**
```
$ git pu[suggestion shows: git push]
  Accept with → 
$ git push
```

---

### `zsh-syntax-highlighting`
**What it does:** Highlights commands, arguments, and errors in real-time as you type.

**Visual feedback:**
- ✅ Valid commands appear in green
- ❌ Unknown commands appear in red
- Arguments, paths, and options are color-coded

**No configuration needed** — works automatically once installed.

---

### `history-substring-search`
**What it does:** Search command history by typing a substring and using arrow keys.

**How to use:**
```bash
# Type the start of a command
$ git pus

# Press Up/Down arrow to cycle through matching commands
$ git push origin main
$ git push
$ git push --force-with-lease
```

Bindings:
- `↑` / `↓` — search history for substring
- `Ctrl+N` / `Ctrl+P` — alternative bindings

---

## Additional Plugins Worth Considering

These play well with **Ghostty** (your terminal) or general workflow:

### `colored-man-pages`
Adds syntax highlighting to man pages. Useful when reading documentation.

### `command-not-found`
Suggests packages to install when you run a command that doesn't exist (macOS/Homebrew aware).

### `copyfile`
Alias: `copyfile <file>` — copies file contents to clipboard (respects Ghostty's tmux integration).

### `direnv`
Auto-loads `.envrc` files when you enter a directory (great for project-specific environment setup).

### `nix-shell`
Integrates nix-shell into your prompt (shows active nix environment).

### `tmux`
Aliases for tmux operations. Since you use tmux, this could be handy:
- `ta` → `tmux attach-session -t`
- `tl` → `tmux list-sessions`
- `tn` → `tmux new-session -s`

---

## Terminal-Specific: Ghostty Integration

Since you use **Ghostty**, consider:

1. **Ghostty keybinds** — fzf's `Ctrl+R`, `Ctrl+T`, `Alt+C` work great in Ghostty
2. **Clipboard** — Ghostty respects system clipboard (OMZ `copyfile` plugin can leverage this)
3. **True color** — Syntax highlighting and colored man pages look sharp in Ghostty

No special OMZ plugin needed for Ghostty specifically, but the ones above complement it well.

---

## Next Steps

When migrating to nix (Home Manager):
- All plugins will be configured declaratively
- No manual installation needed
- Theme (`robbyrussell`) + environment variables persist

See `~/.claude/learnings/fzf-git-plugin.md` for additional fzf-git.sh setup (fuzzy git checkout).

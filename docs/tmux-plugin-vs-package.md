# tmux: Plugin vs Package vs Other

## The Three Ways to Get tmux

### 1. **Package** (Home Manager)
Add to your nix packages in `common.nix`:

```nix
home.packages = with pkgs; [
  tmux
];
```

**What you get:**
- tmux binary installed
- Nothing else — no aliases, no config
- You manually write/manage your `~/.tmux.conf`

**When to use:** Simple, you want full control over config.

---

### 2. **oh-my-zsh Plugin**
Add to your zsh plugins:

```nix
programs.zsh.plugins = [
  { name = "tmux"; }
];
```

**What you get:**
- Convenient aliases for tmux operations:
  - `ta <session>` → `tmux attach-session -t <session>`
  - `tl` → `tmux list-sessions`
  - `tn <session>` → `tmux new-session -s <session>`
  - `ts` → `tmux send-keys -t`
  - ~15 more
- **Does NOT install tmux** — you still need the package
- Useful if you use tmux frequently and want shortcuts

**When to use:** You use tmux a lot and want quick aliases.

---

### 3. **Home Manager `programs.tmux`** (full config)
Configure tmux declaratively in nix:

```nix
programs.tmux = {
  enable = true;
  baseIndex = 1;
  mouse = true;
  keyMode = "vi";
  plugins = [
    {
      plugin = pkgs.tmuxPlugins.vim-navigate;
      extraConfig = "...";
    }
  ];
};
```

**What you get:**
- tmux binary installed
- Your `~/.tmux.conf` auto-generated from nix config
- Plugin management via nix
- Everything declarative

**When to use:** You want your entire tmux config reproducible in nix.

---

## Comparison

| Aspect | Package | Plugin | programs.tmux |
|--------|---------|--------|---------------|
| Installs tmux? | ✅ Yes | ❌ No | ✅ Yes |
| Provides aliases? | ❌ No | ✅ Yes | ❌ No |
| Manages config? | ❌ No | ❌ No | ✅ Yes |
| Manages plugins? | ❌ No | ❌ No | ✅ Yes |
| Effort to set up | Low | Very low | Medium |
| Flexibility | High | N/A | Medium |

---

## Recommendation for you

**Use both:**

1. **Package + oh-my-zsh plugin:**
   ```nix
   # In home.packages
   tmux
   
   # In zsh plugins
   { name = "tmux"; }
   ```
   
   Gives you tmux + convenient aliases with minimal config.

2. **OR: If you want full control:**
   - Use `programs.tmux` in nix (manage entire config declaratively)
   - Skip the oh-my-zsh plugin (redundant)

---

## Your current setup

You already have `~/.tmux.conf` in your dotfiles. So:

**Option A (easiest):**
- Add `tmux` package to nix
- Keep `~/.tmux.conf` as-is (symlink it via nix)
- Add oh-my-zsh tmux plugin for aliases

**Option B (most nix-idiomatic):**
- Migrate `~/.tmux.conf` to `programs.tmux` in nix
- Let nix manage it declaratively
- Skip the plugin

For now, **Option A** (package + plugin) is simpler if you like your current tmux config.

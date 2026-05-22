# macOS-specific configuration
{ config, pkgs, lib, dotfilesDir, ... }:

{
  home.packages = with pkgs; [
    # macOS-specific tools (GUI apps installed via brew below)
    uv  # For installing ty (Python type checker not yet in nixpkgs)
    nodejs  # includes npm
    tmux
  ];

  # Tmux config symlink
  home.file.".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/tmux.conf";

  # Tmux helper scripts
  home.file.".local/bin/ta".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/scripts/ta";
  home.file.".local/bin/tmux-session-using-fzf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/scripts/tmux-session-using-fzf";
  home.file.".local/bin/clipboard-sync".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/scripts/clipboard-sync";

  # Install apps via Homebrew (not available in nixpkgs for macOS)
  home.activation.brewInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v brew &> /dev/null; then
      brew list --cask hammerspoon &> /dev/null || brew install --cask hammerspoon
      brew list --cask ghostty &> /dev/null || brew install --cask ghostty
      brew list --cask claude-code &> /dev/null || brew install --cask claude-code
      brew list --cask kanri &> /dev/null || brew install --cask kanri
      brew list --cask superwhisper &> /dev/null || brew install --cask superwhisper
      brew list --cask keycastr &> /dev/null || brew install --cask keycastr
      brew list --cask wireshark &> /dev/null || brew install --cask wireshark
      brew list pkgx &> /dev/null || brew install pkgx
    fi
  '';

  # Clone work repos if absent
  home.activation.cloneRepos = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export GIT_SSH_COMMAND=/usr/bin/ssh
    clone_if_absent() {
      local dir="$1" url="$2"
      if [ ! -d "$dir" ]; then
        mkdir -p "$(dirname "$dir")"
        ${pkgs.git}/bin/git clone "$url" "$dir"
      fi
    }

    clone_if_absent "$HOME/src/amplify-education/desmos-classroom" "git@github.com:amplify-education/desmos-classroom.git"
    clone_if_absent "$HOME/src/amplify-education/terraform-config" "git@github.com:amplify-education/terraform-config.git"
    clone_if_absent "$HOME/src/magenta.nvim" "git@github.com:dlants/magenta.nvim.git"

    # Convenience symlink: ~/classroom → desmos-classroom repo
    ln -sfn "$HOME/src/amplify-education/desmos-classroom" "$HOME/classroom"
  '';

  # Clone claude-config and symlink its top-level entries into ~/.claude/
  # Existing files in ~/.claude/ that collide are backed up to .bak.<timestamp>.
  home.activation.setupClaudeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export GIT_SSH_COMMAND=/usr/bin/ssh
    CLAUDE_CONFIG_DIR="$HOME/src/claude-config"
    CLAUDE_HOME="$HOME/.claude"

    if [ ! -d "$CLAUDE_CONFIG_DIR/.git" ]; then
      mkdir -p "$(dirname "$CLAUDE_CONFIG_DIR")"
      ${pkgs.git}/bin/git clone "git@github.com:teachermugabo/claude-config.git" "$CLAUDE_CONFIG_DIR"
    fi

    mkdir -p "$CLAUDE_HOME"

    for src in "$CLAUDE_CONFIG_DIR"/* "$CLAUDE_CONFIG_DIR"/.[!.]*; do
      [ -e "$src" ] || continue
      name="$(basename "$src")"
      [ "$name" = ".git" ] && continue
      target="$CLAUDE_HOME/$name"

      if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        continue
      fi

      if [ -e "$target" ] || [ -L "$target" ]; then
        backup="$target.bak.$(date +%Y%m%d%H%M%S)"
        echo "claude-config: backing up $name -> $(basename "$backup")"
        mv "$target" "$backup"
      fi

      ln -sfn "$src" "$target"
    done
  '';

  # Hammerspoon config (macOS-only, uses ~/.hammerspoon not XDG)
  home.file.".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/hammerspoon";

  # Fish config (macOS-specific)
  xdg.configFile."fish/config.fish".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/config-darwin.fish");

  # Ghostty config (macOS-only terminal)
  xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ghostty";
}

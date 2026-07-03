# Shared configuration for all platforms
{ config, pkgs, lib, dotfilesDir, ... }:

{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Enable flakes
  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Common packages
  home.packages = with pkgs; [
    # Dev tools
    ripgrep
    fd
    fzf
    delta  # git-delta
    gh     # GitHub CLI
    rustup
    tree-sitter
    git    # needed for fzf-git.sh
    # jujutsu  # jj version control

    # Language servers
    lua-language-server
    typescript
    typescript-language-server
    bash-language-server
    yaml-language-server
    vscode-langservers-extracted

    # Formatters
    prettier
    stylua
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "T. Mugabo Uwilingiyimana";
        email = "955064+teachermugabo@users.noreply.github.com";
      };
      # alias = {
      #   co = "checkout";
      # };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };

  # Zsh shell with oh-my-zsh
  # NOTE: Sensitive environment variables (PIP_INDEX_URL, UV_INDEX_URL, SSH_AUTH_SOCK,
  # AWS_PROFILE, DC_SID) are intentionally kept in ~/.zshrc and excluded from version control.
  # They remain in your shell config and are sourced at startup.
  # See Task #1 (Audit and migrate environment variables to nix safely) for future nix-secrets strategy.
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "fzf"
        "history-substring-search"
        "colored-man-pages"
      ];
    };

    # External plugins (zsh-autosuggestions and zsh-syntax-highlighting)
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
    ];

    initExtra = ''
      # pyenv initialization
      eval "$(pyenv init - zsh)"

      # Override gco: fuzzy select without args, git checkout with args
      unalias gco 2>/dev/null
      gco() {
        if [ $# -eq 0 ]; then
          # No args: fuzzy select branch with piped git branch | fzf
          git checkout "$(git branch | fzf | sed 's/^[* ] //')"
        else
          # With args: use git checkout (what OMZ's gco was aliased to)
          git checkout "$@"
        fi
      }

      # Source local sensitive variables (not in version control)
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';

    # Environment variables (safe, static ones)
    sessionVariables = {
      EDITOR = "nvim";

      # Python build dependencies (pyenv + sqlite/tcl-tk)
      LDFLAGS = "-L/opt/homebrew/opt/sqlite/lib -L/opt/homebrew/opt/tcl-tk@8/lib";
      CPPFLAGS = "-I/opt/homebrew/opt/sqlite/include -I/opt/homebrew/opt/tcl-tk@8/include";
      PKG_CONFIG_PATH = "/opt/homebrew/opt/sqlite/lib/pkgconfig:/opt/homebrew/opt/tcl-tk@8/lib/pkgconfig";
      PYTHON_CONFIGURE_OPTS = "--with-tcltk-includes='-I/opt/homebrew/opt/tcl-tk@8/include' --with-tcltk-libs='-L/opt/homebrew/opt/tcl-tk@8/lib -ltcl8.6 -ltk8.6'";
      PYTHON_BUILD_HOMEBREW_OPENSSL_FORMULA = "openssl@3";
    };
  };

  # Starship prompt (supports zsh)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      nodejs
      tree-sitter
    ];
  };

  # Symlink configs (live-linked, not copied to nix store)
  xdg.configFile = {
    "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim/init.lua";
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim/lua";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/starship.toml";
  };

  # TODO(mugabo): REVISIT — Denis's browser automation skill (Puppeteer DSL).
  # Symlinks ~/src/dotfiles/magenta-skills/browser → ~/.claude/skills/browser.
  # Disabled for now — not using it yet. See skill.md in the source dir for what it does.
  # Re-enable by uncommenting the activation block below.
  #
  # home.activation.setupMagentaSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   mkdir -p "$HOME/.claude/skills"
  #   ln -sfn "${dotfilesDir}/magenta-skills/browser" "$HOME/.claude/skills/browser"
  # '';


  # Clone magenta.nvim if it doesn't exist
  home.activation.cloneMagenta = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/src/magenta.nvim" ]; then
      mkdir -p "$HOME/src"
      ${pkgs.git}/bin/git clone https://github.com/dlants/magenta.nvim.git "$HOME/src/magenta.nvim"
    fi
  '';

  # Install ty via uv if not already available (uv may be system-provided on Linux)
  home.activation.installTy = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v ty &> /dev/null; then
      if command -v uv &> /dev/null; then
        uv tool install ty 2>/dev/null || true
      fi
    fi
  '';
}

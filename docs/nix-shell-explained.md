# nix-shell Explained

## What is nix-shell?

`nix-shell` is a way to **temporarily enter an isolated environment** with specific dependencies, without installing them globally.

Think of it as: "spin up a temporary, reproducible dev environment for this project."

## How it works

```bash
# Enter a nix-shell with Node.js 18
nix-shell -p nodejs_18

# Inside the shell, Node is available
node --version
# v18.x.x

# Exit the shell
exit

# Node is gone (not installed globally)
```

## Why it's useful

- **Project isolation** — Python 3.9 for project A, Python 3.11 for project B (no conflicts)
- **Reproducibility** — everyone gets the same versions
- **Clean machine** — don't pollute global PATH with tools you use once
- **No installation side effects** — test a tool without committing to it

## flake.nix + direnv workflow (advanced)

Most teams create a `flake.nix` in their project:

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [ nodejs_18 postgresql ];
      };
    };
}
```

Then use **`direnv`** (oh-my-zsh plugin) to auto-load it:

```bash
# Create .envrc in project root
echo "use flake" > .envrc

# direnv auto-loads flake.nix when you cd into the dir
cd myproject
# → automatically has Node + PostgreSQL in PATH
```

## The oh-my-zsh nix-shell plugin

The `nix-shell` plugin adds:
- Prompt indicator showing you're in a nix-shell
- Convenient commands like `nix-shell-exit` (alias for `exit`)

**Useful if:** you use `nix-shell` frequently for dev work.

## When to use

- **Use `nix-shell`:** for temporary, project-specific environments
- **Use home-manager packages:** for tools you use globally (rg, fd, fzf, nvim)
- **Combine both:** global tools via home-manager, project tools via nix-shell + direnv

## See Also

- `tmux-plugin-vs-package.md` — similar concepts for tmux
- `direnv` — task to investigate setup

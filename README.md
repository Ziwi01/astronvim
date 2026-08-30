# Proveasio Neovim Config

A custom [AstroNvim](https://github.com/AstroNvim/AstroNvim) v4+ configuration that turns
Neovim into a full-featured, terminal-first IDE tuned for development and DevOps/SRE work.

This repository is the default Neovim setup shipped with
[**Proveasio**](https://github.com/Ziwi01/proveasio) — a tool that provisions and maintains
an Ubuntu (including Windows WSL2) terminal development environment. Proveasio installs this
config to `~/.config/nvim` so you get a working IDE out of the box, but the repo also works
perfectly well as a standalone AstroNvim user configuration.

## Highlights

- Based on AstroNvim `^6` with a curated set of [AstroCommunity](https://github.com/AstroNvim/astrocommunity) modules.
- AI-assisted coding: GitHub Copilot (inline + completion source), CodeCompanion, and OpenCode integration.
- First-class Git & GitHub workflow: LazyGit, Fugitive, Diffview, CodeDiff, gh.nvim, Signify, GV.
- Deep language support (Go, Python, Ruby, Java/Spring Boot, Lua, Bash, Ansible, Terraform, Docker, Helm, YAML, JSON, Markdown).
- Seamless TMUX ↔ Neovim navigation and TMUX command execution.
- WSL2-aware clipboard handling and quality-of-life tweaks.

## Requirements

- Neovim `>= 0.10` (a recent stable release is recommended).
- A [Nerd Font](https://www.nerdfonts.com/) for icons (or set `icons_enabled = false` in `lua/lazy_setup.lua`).
- `git`, a C compiler, and `tree-sitter-cli` for Treesitter parsers.
- Optional but recommended: `ripgrep`, `fd`, a running `tmux`, GitHub CLI (`gh`), and the
  `opencode` CLI for the AI terminal integration. On WSL, `win32yank.exe` is used for clipboard.

Installing Proveasio provisions all of these dependencies for you.

## Installation

### Via Proveasio (recommended)

Follow the [Proveasio documentation](https://ziwi01.github.io/proveasio). Proveasio installs
Neovim and deploys this configuration automatically.

### Standalone

Back up any existing Neovim configuration and state first:

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

Clone this repository into your Neovim config directory and start Neovim (plugins install on
first launch):

```shell
git clone https://github.com/Ziwi01/astronvim.git ~/.config/nvim
nvim
```

## Repository structure

```
init.lua                 # Bootstraps lazy.nvim, then loads lazy_setup + polish
lua/lazy_setup.lua       # AstroNvim core spec, leader keys, lazy.nvim options
lua/community.lua        # AstroCommunity module imports
lua/polish.lua           # Final pure-Lua tweaks (autocmds, clipboard, OpenCode)
lua/plugins/             # Plugin overrides and custom plugin specs
```

The leader key is `Space` and the local leader is `,`. The default colorscheme is `astrodark`.

## AstroCommunity modules

Imported in `lua/community.lua`. Grouped by purpose:

- **AI**: `opencode-nvim`, `copilot-lua`, `codecompanion-nvim`
- **Completion (blink)**: `blink-cmp-emoji`, `blink-cmp-git`, `blink-cmp-tmux`
- **Colorscheme / UI**: `nightfox-nvim`, `transparent-nvim`, `mini-icons`, `noice-nvim`,
  `vim-illuminate`, `indent-blankline-nvim`, `mini-indentscope`, `rainbow-delimiters-nvim`,
  `nvim-treesitter-context`
- **Diagnostics**: `trouble-nvim`, `tiny-inline-diagnostic-nvim`
- **Editing**: `multiple-cursors-nvim`, `auto-save-nvim`, `vim-move`, `treesj`, `conform-nvim`,
  `vim-easy-align`, `nvim-surround`
- **Motion**: `flash-nvim`, `leap-nvim`
- **Git**: `blame-nvim`, `openingh-nvim`, `codediff-nvim`
- **Search / navigation**: `telescope-zoxide`, `grug-far-nvim`, `nvim-bqf`
- **LSP**: `inc-rename-nvim`, `nvim-lsp-file-operations`
- **Markdown / LaTeX**: `markview-nvim`
- **Terminal**: `vim-tmux-navigator`
- **Docker**: `lazydocker`
- **Scrolling**: `neoscroll-nvim`
- **Language packs**: `lua`, `ansible`, `bash`, `docker`, `go`, `helm`, `java`, `spring-boot`,
  `markdown`, `python`, `ruby`, `json`, `terraform`, `yaml`

## Custom overrides and plugins (`lua/plugins/`)

### Core (`astrocore.lua`, `astrolsp.lua`, `astroui.lua`)

- Relative + absolute line numbers, line wrapping, `auto` sign column, spell off.
- Diagnostics with underline but **no** virtual text/lines (kept quiet by default).
- Auto project-root detection (`rooter.autochdir`), ignoring the `copilot` server.
- Format-on-save enabled globally (1s timeout), excluding `xml`.
- LSP codelens refresh, semantic tokens on, inlay hints off.
- `gl` mapped to open floating diagnostics.
- `azure_pipelines_ls` schema wiring for YAML files under `.azuredevops/`.
- Colorscheme set to `astrodark`.

### Completion & AI (`blink.lua`, `blink-copilot.lua`, `codecompanion.lua`)

- **blink.cmp**: `super-tab` preset with Copilot-aware keys:
  - `<Tab>` accepts a Copilot inline suggestion (or navigates the menu / expands snippets).
  - `<S-Tab>` dismisses the Copilot suggestion or navigates backward.
  - `<M-]>` / `<M-[>` cycle to the next/previous Copilot suggestion.
  - `<Up>`/`<Down>` are unbound in the completion menu.
  - Sources prioritized as `copilot > lsp > path > snippets > buffer`, with score boosts for
    Copilot, emoji, and git providers.
- **blink-copilot**: larger inline suggestion length (`max_inline_len = 2000`).
- **CodeCompanion**: chat uses the `copilot` adapter with model `claude-sonnet-4.6`.

### Git & GitHub (`diffview.lua`, `gh.lua`, `user.lua`)

- **diffview.nvim** (`dlyongemallo` fork): enhanced diff highlights, winbar info, Neogit
  integration; opens on `:DiffviewOpen`.
- **gh.nvim** + **litee.nvim**: in-editor GitHub PRs, issues, reviews, threads, and commits
  (see keybindings below).
- **vim-fugitive** (`:G <git command>`), **lazygit.nvim** (`<Leader>gg`), **gv.vim** (git
  graph), **vim-signify** (line-level git status), **diffchar.vim** / **vim-dirdiff**
  (precise + directory diffs).

### File tree (`neo-tree.lua`)

Adds a CodeDiff "directory compare" workflow driven from the tree:

- `gm` on a directory marks it as the diff **source** (toggles off if already marked; shown
  with a dimmed `(diff source)` tag).
- `gd` on another directory runs `:CodeDiff dir <source> <target>`.
- Hidden/dotfiles are shown by default; window auto-expand width disabled.

### Navigation & search (`telescope.lua`, `mappings.lua`)

- **telescope-zoxide**: `<Leader>z` jumps to a zoxide directory and opens Neo-Tree there.
- TMUX navigation with `Alt + Arrow` keys (`vim-tmux-navigator`).
- `H` / `L` cycle buffers; `<Leader>bD` picks a buffer to close.
- Visual-mode `p` pastes without overwriting the yank register.

### UI polish (`snacks.lua`, `noice.lua`)

- Custom ASCII-art dashboard header (easy to switch back to the stock AstroNvim art).
- Noice routes that silence "AutoSave" and "Config Change Detected" messages.

### Tooling (`mason.lua`, `treesitter.lua`)

- Mason ensures `lua-language-server`, `stylua`, `debugpy`, and `tree-sitter-cli` are installed.

### Additional plugins (`user.lua`)

- **Copilot** enabled for `yaml` and `yaml.ansible` filetypes.
- **bullets.vim**, **mkdx**, **markdown-plus.nvim**, **vim-table-mode** — Markdown/list authoring.
- **fzf** + **fzf.vim** — fuzzy finding.
- **vim-better-whitespace** — trims trailing whitespace (blacklisted for many UI filetypes).
- **lsp_signature.nvim** — signature help while typing.
- **goto-preview** — preview definitions/implementations in floating windows (`gp*`).
- **vimux** — run commands in a TMUX split.
- **ferret** — project search/replace (`:Ack` / `<Leader>a`, `:Acks` / `<Leader>r`).

## Key bindings reference

Leader is `Space`.

### Buffers & windows

| Key            | Action                          |
| -------------- | ------------------------------- |
| `L` / `H`      | Next / previous buffer          |
| `<Leader>bD`   | Pick a buffer to close          |
| `<A-Arrows>`   | Navigate TMUX/Vim splits        |

### AI / OpenCode

| Key          | Action                                          |
| ------------ | ----------------------------------------------- |
| `<C-.>`      | Toggle the OpenCode terminal (normal/terminal)  |
| `<Leader>O+` | Append `@buffer` to the OpenCode prompt         |

### Git

| Key          | Action        |
| ------------ | ------------- |
| `<Leader>gg` | LazyGit       |
| `<Leader>z`  | Zoxide picker |

### gh.nvim (GitHub)

Grouped under `<Leader>gi`:

- **Pull Requests** `<Leader>gip*`: open, close, details, expand/collapse, refresh, pop-out, open-to.
- **Commits** `<Leader>gic*`: open-to, close, expand/collapse, pop-out.
- **Issues** `<Leader>giip`: preview issue.
- **Reviews** `<Leader>gir*`: begin, submit, close, delete, expand/collapse.
- **Threads** `<Leader>git*`: create, next, toggle.
- `<Leader>gil`: toggle the litee panel.

### Neo-Tree diff workflow

| Key  | Action                                                  |
| ---- | ------------------------------------------------------- |
| `gm` | Mark directory under cursor as CodeDiff source          |
| `gd` | Diff marked source against directory under cursor       |

## `polish.lua` behaviors

- Restores the cursor to its last position when reopening a file.
- Treats `zsh` files with Bash Treesitter highlighting; forces `Jenkinsfile` to `groovy`.
- On WSL, routes the system clipboard through `win32yank.exe` (avoids OSC 52 leakage from TUI
  apps like OpenCode running in the built-in terminal).
- Configures the OpenCode server to launch inside a right-hand Snacks terminal split.

## Customizing

- Add or remove community modules in `lua/community.lua`.
- Add plugin specs or overrides in `lua/plugins/` (any `.lua` file returning a LazySpec is loaded).
- Put final pure-Lua tweaks (autocmds, filetypes, globals) in `lua/polish.lua`.

## Credits

- Built on [AstroNvim](https://github.com/AstroNvim/AstroNvim) and [AstroCommunity](https://github.com/AstroNvim/astrocommunity).
- Maintained as part of [Proveasio](https://github.com/Ziwi01/proveasio) by Eryk 'Ziwi' Kozakiewicz.

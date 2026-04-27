# Dotfiles

Personal configuration files.

- `.gitconfig` — Git configuration
- `.bashrc` — Bash config (no oh-my-bash; built-in `cdspell` + a case-insensitive `cd` fallback so `cd ass` finds `Ass/`)
- `nvim/` — Neovim configuration (packer, kanagawa theme, nvim-tree, lualine, dashboard)
- `agents/` — Portable agentic-coding bundle (drop into a project repo when needed; not loaded globally)
- `install.sh` — One-liner bootstrap for a fresh machine

## One-liner install

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/DeltaVector1/dotfiles/master/install.sh)
```

It will ask, in order:
1. Which agent? `claude` / `codex` / `both` / `skip` — drops the matching files from `agents/` into the current directory
2. Install nvim config to `~/.config/nvim`?
3. Replace `~/.bashrc`?
4. Replace `~/.gitconfig`?

Then unconditionally installs [astral uv](https://docs.astral.sh/uv/) (skipped if already present).

Existing files are backed up to `*.bak.<timestamp>` before being replaced.

The script is a subshell — it cannot mutate your parent terminal's `PATH`. After it finishes, run `exec $SHELL -l` to pick up uv in the current shell, or just open a new terminal. The shipped `.bashrc` adds `~/.local/bin` to `PATH` so uv is on it from then on.

## agents/ — portable coding-agent bundle

Drop the contents into any project repo when you want coding-agent rules + skills there. It is not loaded globally on purpose, so non-coding work (e.g. cowriting) isn't polluted by coding instructions.

```
agents/
├── CLAUDE.md                    # working-style rules; Claude Code reads this
├── AGENTS.md                    # identical to CLAUDE.md; Codex (and others) read this
├── .claude/
│   ├── commands/                # Claude Code slash commands
│   │   ├── deslop.md
│   │   └── Create-Agents-File.md
│   └── skills/                  # Claude Code skills (SKILL.md format)
│       └── frontend-design/SKILL.md
└── .agents/skills/              # Codex skills (per https://developers.openai.com/codex/skills)
    ├── deslop/SKILL.md
    ├── create-agents-file/SKILL.md
    └── frontend-design/SKILL.md
```

`frontend-design` is Anthropic's official skill ([upstream](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design)) — kept verbatim with its license alongside.

To use it in a target repo:

```sh
cp -R ~/Documents/dotfiles/agents/. /path/to/target-repo/
```

That gives the target repo:
- `CLAUDE.md` + `AGENTS.md` at the root → both Claude Code and Codex pick up the working-style rules
- `.claude/commands/*.md` → invocable in Claude Code as `/deslop`, `/Create-Agents-File`
- `.agents/skills/*/SKILL.md` → invocable in Codex; Codex discovers `.agents/skills` from the working directory up to the git root

# Theming

One palette — WebStorm's **Material Darker**, as personally modified — applied across
the terminal stack so the same code looks the same everywhere.

## Source of truth

`~/Material_Darker.icls`, exported from WebStorm:
*Settings → Editor → Color Scheme → ⚙ → Export → IntelliJ IDEA color scheme (.icls)*

It is XML: `<colors>` holds editor chrome (`CARET_ROW_COLOR`, `SELECTION_BACKGROUND`, …),
`<attributes>` holds syntax roles (`DEFAULT_KEYWORD`, `DIFF_INSERTED`, `CONSOLE_*_OUTPUT`, …)
with `FONT_TYPE` 1=bold 2=italic 3=both. **Never hand-pick a colour** — look it up there.
Re-export after changing the scheme in WebStorm, then re-derive whatever it affects.

## Layers

| layer | file | notes |
|---|---|---|
| nvim | `.config/nvim/lua/plugins/colorscheme.lua` | catppuccin repainted: `color_overrides` (palette) + `highlight_overrides.macchiato` (roles) + terminal palette |
| nvim | `.config/nvim/lua/config/autocmds.lua` | `theme_tweaks()` — theme-agnostic, derives from the active colorscheme |
| nvim | `.config/nvim/after/queries/{typescript,tsx}/highlights.scm` | import + JSX captures treesitter gets wrong |
| terminal | `.config/ghostty/config` | `theme = Material Darker` + palette fixes |
| tmux | `.config/tmux/tmux.conf` | `@thm_*` set **before** the catppuccin plugin runs |
| prompt | `dot_p10k.zsh` | all colours are `#rrggbb` |
| pagers | `dot_gitconfig` `[delta]`, `.config/bat/themes/Material Darker.tmTheme` | delta reads git config; bat theme also drives delta's syntax |
| tools | `.config/atuin/themes/material-darker.toml`, `.config/lazygit`, `dot_zshrc` (fzf) | |

## Principles

1. **Inherit over hardcode.** fzf uses `--color=base16` and atuin uses role names, so both
   follow the terminal palette with no hexes of their own. Prefer this whenever it exists.
2. **Name groups, don't copy values.** snacks' lazygit accent points at `Constant`, so it
   tracks whatever theme is loaded. Same for `theme_tweaks()` in nvim.
3. **Better beats faithful.** The `.icls` is a reference, not a spec. Deviations, all deliberate:
   grey `DIFF_DELETED` → a faint red (scannability); markdown headings keep catppuccin's
   graded colours (render-markdown needs six distinguishable levels, WebStorm uses font size);
   `ColorColumn` stays dim (nvim fills a cell, WebStorm draws a 1px rule); ANSI cyan is the
   palette's teal, not `CONSOLE_CYAN_OUTPUT` (too close to ANSI blue to tell apart).
4. **Decouple.** Plugins derive colours from unrelated groups — snacks took lazygit's accent
   from `MatchParen`, render-markdown takes `H4Bg` from `DiffDelete`. State those explicitly
   instead of bending the source group.

## Traps

Each of these cost real debugging time and fails **silently**:

- **zsh: quote hex.** `FOREGROUND=#c3e88d` under `extended_glob` + brace expansion is a glob,
  not an assignment (`no matches found`), and one failure aborts the whole p10k config — every
  later segment silently reverts to defaults. The p10k README quotes it for this reason.
- **nvim queries need `; extends`.** `; inherits: <lang>` alone does not register an override
  file; it is dropped entirely while its inherits still run. See `:h treesitter-query` and
  `runtime/lua/vim/treesitter/query.lua`.
- **Never flavour-guard `custom_highlights`.** catppuccin hashes config by *calling* the
  function, so a guarded early-return hashes identically on every edit and the compiled cache
  is never invalidated. Use `highlight_overrides.<flavour>` — it needs no guard.
- **tmux `run-shell` does not read `~/.zshrc`.** Anything a keybinding shells out to needs
  `set-environment -g`.
- **Ghostty: last directive wins.** Duplicate `palette = N=` lines silently override earlier ones.
- **bat: run `bat cache --build`** after editing the `.tmTheme`, or nothing changes.
- **chezmoi: new files are unmanaged.** `chezmoi re-add` only updates known files; a new one
  needs `chezmoi add` or it is lost on the next `apply`. Check `chezmoi status` before stopping.

## Diagnosing

Colour questions are answerable, not guessable — screenshots lie, terminal opacity lies.

- **What colour is actually rendered:** run it under tmux and read the escape codes.
  `tmux new-session -d -s x -x 200 -y 20 "<cmd>"; tmux capture-pane -pet x` then parse
  `38;2;R;G;B`. Works for nvim, fzf, lazygit, bat — anything.
- **nvim, which group owns a token:** `:Inspect` on the cursor. Treesitter priority 100,
  LSP semantic tokens 125, so `@lsp.*` wins where the language server has an opinion.
- **bat/delta, which scope owns a token:** append rules with marker colours (`#010101` per
  candidate scope), rebuild, render, see which one paints it.
- **nvim headless is a false negative** — LazyVim loads config on `VeryLazy`, which never
  fires without a UI. Always test through tmux.

## Known gaps

- `import { PascalCaseConst }` reads as a function. Type imports and `ALL_CAPS` are handled;
  a PascalCase non-type import is indistinguishable from a component without resolution.
- atuin paints the focused row with `AlertError` — no separate role exists, so selection and
  errors share a colour.
- The `.tmTheme` still carries teal for languages with no `.icls` opinion (C++, Julia, LaTeX).

# Theming

One palette — WebStorm's **Material Darker**, as personally modified — applied across
the terminal stack so the same code looks the same everywhere.

## Source of truth

`~/.config/themes/Material_Darker.icls`, managed by chezmoi and exported from WebStorm:
*Settings → Editor → Color Scheme → ⚙ → Export → IntelliJ IDEA color scheme (.icls)*

It is XML: `<colors>` holds editor chrome (`CARET_ROW_COLOR`, `SELECTION_BACKGROUND`, …),
`<attributes>` holds syntax roles (`DEFAULT_KEYWORD`, `DIFF_INSERTED`, `CONSOLE_*_OUTPUT`, …)
with `FONT_TYPE` 1=bold 2=italic 3=both. **Never hand-pick a colour** — look it up there.
Re-export to that path after changing the scheme in WebStorm, then run
`chezmoi re-add ~/.config/themes/Material_Darker.icls` and re-derive whatever it affects.
Find its version-controlled source with `chezmoi source-path ~/.config/themes/Material_Darker.icls`.

## Layers

| layer | file | notes |
|---|---|---|
| nvim | `.config/nvim/lua/material-darker.lua` | Material palette, syntax roles, terminal colours, and Catppuccin-backed loader |
| nvim | `.config/nvim/colors/material-darker.lua` | `:colorscheme material-darker` entry point |
| nvim | `.config/nvim/lua/plugins/colorscheme.lua`, `.config/nvim/lua/lualine/themes/material-darker.lua` | default selection, Catppuccin dependency, bufferline/lualine adapters |
| nvim | `.config/nvim/lua/config/autocmds.lua` | `theme_tweaks()` — theme-agnostic, derives from the active colorscheme |
| nvim | `.config/nvim/after/queries/{typescript,tsx}/highlights.scm` | import + JSX captures treesitter gets wrong |
| terminal | `.config/ghostty/config` | `theme = Material Darker` + palette fixes |
| tmux | `.config/tmux/tmux.conf` | `@thm_*` set **before** the catppuccin plugin runs |
| prompt | `dot_p10k.zsh` | all colours are `#rrggbb` |
| pagers | `dot_gitconfig` `[delta]`, `.config/bat/themes/Material Darker.tmTheme` | delta reads git config; bat theme also drives delta's syntax |
| tools | `.config/atuin/themes/material-darker.toml`, `.config/lazygit`, `dot_zshrc` (fzf) | |

## Neovim theme

The default is **`material-darker`**, also selectable with `:colorscheme material-darker`
or `<leader>uC`. Catppuccin remains the rendering/integration dependency, not a fork.
Internally Material supplies the macchiato palette/role overrides to its engine; selecting
`catppuccin-macchiato` now restores genuine Macchiato (with the existing global transparency
setting), as do the other real flavours. `ColorSchemePre` restores Catppuccin's base options
before loading a real flavour and clears Material's terminal colours when leaving Material.
The loader calls the engine directly, so there is only one `ColorScheme` event per selection.

Keep the bufferline adapter and lualine alias: their automatic theme detection otherwise
misses the new name. Queries, `theme_tweaks()`, rainbow indents, and CodeDiff settings remain
where they were; extraction does not change their behavior.

## Principles

1. **Inherit over hardcode.** fzf uses `--color=base16` and atuin uses role names, so both
   follow the terminal palette with no hexes of their own. Prefer this whenever it exists.
2. **Name groups, don't copy values.** snacks' lazygit accent points at `UiAccent`, so it
   tracks whatever theme is loaded. Same for `theme_tweaks()` in nvim.
3. **Better beats faithful.** The `.icls` is a reference, not a spec. Deviations, all deliberate:
   grey `DIFF_DELETED` → a faint red (scannability); markdown headings keep catppuccin's
   graded colours (render-markdown needs six distinguishable levels, WebStorm uses font size);
   `ColorColumn` stays dim (nvim fills a cell, WebStorm draws a 1px rule); ANSI cyan is the
   palette's teal, not `CONSOLE_CYAN_OUTPUT` (too close to ANSI blue to tell apart).
4. **Decouple.** Plugins derive colours from unrelated groups — snacks took lazygit's accent
   from `MatchParen`, render-markdown takes `H4Bg` from `DiffDelete`. State those explicitly
   instead of bending the source group.

## Changing a colour

Approximate blast radius per role, counted across the dotfiles repo. Every hex maps to
exactly one role — no colour means two different things — so a blind substitution is safe.

| hex | role | occurrences |
|---|---|---|
| `#212121` | background | 10 |
| `#1a1a1a` | dimmed / inactive pane | 4 |
| `#353535` | selection | 7 |
| `#424242` | border, gutter, line numbers | 15 |
| `#616161` | comment, dim text | 14 |
| `#90a4ae` | subtext | 12 |
| `#b2ccd6` | muted text | 8 |
| `#eeffff` | text | 29 |
| `#ff9800` | accent — active pane/panel/row | 16 |
| `#ff5370` | error | 27 |
| `#f07178` | tag, soft red, removed lines | 12 |
| `#f78c6c` | number, constant, parameter | 37 |
| `#ffcb6b` | type, warning, search match | 37 |
| `#c3e88d` | string, added lines | 44 |
| `#80cbc4` | teal, ANSI cyan | 48 |
| `#89ddff` | punctuation, operators | 23 |
| `#82aaff` | function, link, info | 49 |
| `#c792ea` | keyword | 34 |

To change one, edit the source (not `~`), then re-apply:

```sh
S=~/.local/share/chezmoi
grep -rlI '#ff9800' --exclude-dir=.git "$S" | xargs sed -i '' 's/#ff9800/#ffa726/gI'
chezmoi apply && bat cache --build
```

Then reload what does not pick it up automatically: Ghostty (`cmd+shift+,`),
`tmux source ~/.config/tmux/tmux.conf`, restart nvim and any running pi/lazygit.
Colours that live only in nvim (`#033e5d`, `#3b514d`, `#4a4d50`, `#f071d0`, `#ffe153`,
`#ffeb95`) are in `lua/material-darker.lua` alone.

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
- **Scope a rule to the language it came from.** `JS.GLOBAL_FUNCTION` is yellow italic, but
  `DEFAULT_FUNCTION_DECLARATION` is blue — applying the JS rule globally made every Go and
  Python function yellow, unnoticed. nvim exposes `@lsp.type.<kind>.<filetype>` (filetype,
  so `typescriptreact` not `tsx`), so define the generic group from the `DEFAULT_*` key and
  override per language. The same applies to `@property` vs `@property.yaml`/`.json`.
- **Ghostty rejects a value with a trailing comment**, silently, and falls back to the theme's
  value. Comments need their own line. `ghostty +show-config` prints what actually resolved.
- **Plugins derive colours from groups you never meant for them.** snacks built lazygit's
  accent from `MatchParen`, render-markdown builds heading backgrounds from `DiffDelete` /
  `Visual` / `CursorColumn`, and codediff derives its character-level diff band from
  `DiffAdd` x 1.4. That last one produced `#566048` against Material's comment grey
  `#616161` — different hues, luminance 0.108 vs 0.117, so **1.05:1** and invisible. Pin
  such colours explicitly (`line_insert`/`line_delete`, `char_brightness = 1.0`) instead of
  letting them be computed. When a plugin looks wrong, grep *its* source for the group it
  reads before touching the theme.
- **Check luminance, not hue, for text on a tinted background.** Comment `#616161` sits at
  luminance 0.117, so *any* background between ~0.02 and ~0.2 collapses its contrast toward
  1:1 no matter what colour it is. Material's own `DIFF_INSERTED` (`#264b33`) still only gives
  1.59:1. A tint that "looks dark" is not necessarily safe.
- **Run `chezmoi diff <file>` before `re-add`.** A file showing modified in `chezmoi status`
  may mean the *source* is stale, not the target — `oxfmt.lua` had a richer live version that
  `chezmoi apply` would have silently reverted.
- **Nothing may `require("catppuccin")` before the colorscheme loads.** `material-darker.lua` skips
  the stock `setup` only when Catppuccin is first pulled in by its own `load()`; an earlier
  require sets up (and eagerly compiles) stock colours, then Material compiles again — two
  compiles every startup, silently.

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

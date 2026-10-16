# mdotfiles

My macOS dotfiles. One folder, symlinked into `~/.config` — everything is edited right here. The Mac twin of my Linux `jdotfiles`: same idea, same commands.

## What's inside

- **OmniWM** — window manager settings (master-stack layout, Option-key scheme that mirrors my Linux Super keybinds)
- **skhd** — hotkeys (launcher, files, lock, Geany, quit-app)
- **Kitty** — terminal
- **SketchyBar** — menu bar
- **`shell/zshrc`** — my zshrc (bare `brew` updates everything: formulae + casks)

## Hot-swapping (`dots` / `dot`)

```
dots            # show the active set
dots mdotfiles  # this set
dot             # TUI picker (fzf) — pick a set, it applies and refreshes live
```

Swapping repoints every symlink and refreshes skhd + SketchyBar live, no logout.
Any folder in `~` with a `.config/omniwm` inside shows up in the picker automatically.

## Keybinds

Modifier is **Option** — the same spots as Super on my Linux setup: `` ` `` terminal, B browser, R files, E launcher, G Geany, Q close, Shift+Q kill app, F fullscreen, M maximize, T floating, X split, Shift+R reload, L lock, 1–5 workspaces.

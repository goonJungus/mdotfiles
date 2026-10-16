
# iluvgirlswithglasses' SketchyBar

<img width="1238" height="800" alt="desktop-1-800-sharp" src="https://github.com/user-attachments/assets/170fb02f-9477-4d86-96ea-c67dbc1a3394" />

## Dependencies

Install Lua SketchyBar, OmniWM, as well as some fonts and CLI tools:

```sh
brew tap FelixKratz/formulae
brew install felixkratz/formulae/sketchybar media-control jq lua
brew install --cask omniwm font-space-mono-nerd-font font-gabarito

xcode-select --install
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
```

## Installation

```sh
# clone this repo:
git clone https://github.com/iluvgirlswithglasses/sketchybar ~/.config/sketchybar

# start sketchybar services:
brew services start felixkratz/formulae/sketchybar

# if you already have a sketchybar instance running:
sketchybar --reload
```

## Notes

This config geometry is calibrated for a 16 inch MacBook. Edit `./theme/metrics.lua` to fit your screen size.

<img width="1920" height="854" alt="real-life-txt" src="https://github.com/user-attachments/assets/2a580899-709e-4142-b07f-83ee5477b195" />


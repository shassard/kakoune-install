#!/bin/bash

set -ex

# kakoune
sudo apt install libncursesw5-dev pkg-config
git clone https://github.com/mawww/kakoune.git
PREFIX="$HOME"/.local make -j12 -C kakoune/src install

# kak-lsp
cargo install -f --git https://github.com/ul/kak-lsp
mkdir -p "$HOME"/.config/kak-lsp
curl -L https://raw.githubusercontent.com/ul/kak-lsp/master/kak-lsp.toml | sed "s/\"rls\"/\"ra_lsp_server\"/g" > "$HOME"/.config/kak-lsp/kak-lsp.toml

# clippy
rustup component add clippy

# rust-src
rustup component add rust-src

# rust-analyzer
cargo install -f --git https://github.com/rust-analyzer/rust-analyzer ra_lsp_server # this should work, but seems to be bad
#git clone git@github.com:rust-analyzer/rust-analyzer
#pushd .
#cd rust-analyzer
#cargo xtask install --server
#popd

# rls
#rustup component add rls rust-analysis

# kakrc
mkdir -p "$HOME"/.config/kak
cat > "$HOME"/.config/kak/kakrc << EOF
set-option global ui_options ncurses_assistant=off
set-option global tabstop     4
set-option global indentwidth 4
add-highlighter global/ number-lines -relative -hlcursor
add-highlighter global/ show-matching
add-highlighter global/ regex '\h+$' 0:Error

colorscheme gruvbox

eval %sh{kak-lsp --kakoune -s \$kak_session}
lsp-enable
set-option global lsp_server_configuration rust.clippy_preference="on"
EOF

# autoloads
mkdir -p "$HOME"/.config/kak/autoload
if [ ! -L "$HOME"/.config/kak/autoload/default ]; then
 echo creating autoload symlink
 ln -s "$HOME"/.local/share/kak/autoload "$HOME"/.config/kak/autoload/default
fi
curl -o "$HOME"/.config/kak/autoload/cargo.kak https://gitlab.com/Screwtapello/kakoune-cargo/raw/master/cargo.kak

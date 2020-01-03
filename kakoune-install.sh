#!/bin/bash

set -ex

# kakoune
sudo apt install libncursesw5-dev pkg-config
git clone https://github.com/mawww/kakoune.git
PREFIX="$HOME"/.local nice make -j12 -C kakoune/src install

# kak-lsp
curl -L https://github.com/ul/kak-lsp/releases/download/v7.0.0/kak-lsp-v7.0.0-x86_64-unknown-linux-musl.tar.gz | tar -xz
mkdir -p "$HOME"/.local/bin
cp kak-lsp "$HOME"/.local/bin/
mkdir -p "$HOME"/.config/kak-lsp
sed "s/rls/ra_lsp_server/g" kak-lsp.toml > "$HOME"/.config/kak-lsp/kak-lsp.toml

# clippy
rustup component add clippy

# rls
#rustup component add rls rust-analysis rust-src

# rust-analyzer
git clone https://github.com/rust-analyzer/rust-analyzer
pushd .
cd rust-analyzer
nice cargo xtask install --server
popd

# kakrc
mkdir -p "$HOME"/.config/kak
cat > "$HOME"/.config/kak/kakrc << EOF
eval %sh{kak-lsp --kakoune -s \$kak_session}
lsp-enable
set-option global lsp_server_configuration rust.clippy_preference="on"
set global ui_options ncurses_assistant=off
add-highlighter global/ number-lines -relative
add-highlighter global/ show-matching
EOF

# autoloads
mkdir -p "$HOME"/.config/kak/autoload
if [ ! -L "$HOME"/.config/kak/autoload/kak ]; then
 echo creating autoload symlink
 ln -s "$HOME"/.local/share/kak "$HOME"/.config/kak/autoload/kak
fi
curl -o "$HOME"/.config/kak/autoload/cargo.kak https://gitlab.com/Screwtapello/kakoune-cargo/raw/master/cargo.kak 

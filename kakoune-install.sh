#!/bin/bash

set -ex

# kakoune
if [ "$(uname)" == "Linux" ]; then
    if [ -f /usr/bin/dpkg ]; then
        BUILDPKGS="libncursesw5-dev pkg-config"
        for PKG in $BUILDPKGS; do
            if ! dpkg -s "$PKG" > /dev/null ; then
                sudo apt -y install "$PKG"
            fi
        done
    elif [ -f /usr/bin/rpm ]; then
        BUILDPKGS="ncurses-devel pkgconf-pkg-config"
        for PKG in $BUILDPKGS; do
            if ! rpm -qi "$PKG" > /dev/null ; then
                sudo dnf -y install "$PKG"
            fi
        done
    fi
fi
git clone --depth=1 https://github.com/mawww/kakoune.git || true
PREFIX="$HOME"/.local make -j12 -C kakoune/src install

# plug.kak
mkdir -p "$HOME"/.config/kak/plugins
PLUGPATH="$HOME"/.config/kak/plugins/plug.kak
if [ ! -f "$PLUGPATH" ]; then
 git clone https://github.com/andreyorst/plug.kak.git "$PLUGPATH" || true
fi
git -C "$PLUGPATH" checkout dev

# kak-lsp
cargo install --git https://github.com/ul/kak-lsp
mkdir -p "$HOME"/.config/kak-lsp
curl -L https://raw.githubusercontent.com/ul/kak-lsp/master/kak-lsp.toml | sed "s/\"rls\"/\"rust-analyzer\"/g" > "$HOME"/.config/kak-lsp/kak-lsp.toml

# clippy
rustup component add clippy

# rust-src
rustup component add rust-src

# rust-analyzer
cargo install --git https://github.com/rust-analyzer/rust-analyzer rust-analyzer

# kakrc
mkdir -p "$HOME"/.config/kak
cat > "$HOME"/.config/kak/kakrc << EOF
source "%val{config}/plugins/plug.kak/rc/plug.kak"
set-option global plug_always_ensure true
set-option global ui_options ncurses_assistant=off
#set-option global tabstop 4
set-option global indentwidth 4
add-highlighter global/ number-lines -relative -hlcursor
add-highlighter global/ show-matching
add-highlighter global/ regex '\h+$' 0:Error
colorscheme gruvbox
eval %sh{kak-lsp --kakoune -s \$kak_session}
hook global WinSetOption filetype=(rust|python|go) %{
	lsp-enable-window
}
set-face global DiagnosticError default+u
set-face global DiagnosticWarning default+u
set-option global lsp_server_configuration rust.clippy_preference="on"
map global user l ':enter-user-mode lsp<ret>' -docstring 'enter lsp user mode'
plug "lePerdu/kakboard" ensure config %{
    hook global WinCreate .* %{ kakboard-enable }
}
hook global WinCreate .* %{ git show-diff }
EOF

# autoloads
mkdir -p "$HOME"/.config/kak/autoload

if [ ! -L "$HOME"/.config/kak/autoload/default ]; then
 echo creating autoload symlink
 if [ -L /usr/share/kak/autoload ]; then
      ln -s /usr/share/kak/autoload "$HOME"/.config/kak/autoload/default
 elif [ -L /usr/local/share/kak/autoload ]; then
   ln -s /usr/local/share/kak/autoload "$HOME"/.config/kak/autoload/default
 elif [ -L "$HOME"/.local/share/kak/autoload ]; then
   ln -s "$HOME"/.local/share/kak/autoload "$HOME"/.config/kak/autoload/default
 else
   echo "failed to find kakoune default autoload path."
 fi
fi
curl -o "$HOME"/.config/kak/autoload/cargo.kak https://gitlab.com/Screwtapello/kakoune-cargo/raw/master/cargo.kak

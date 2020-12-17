source "%val{config}/plugins/plug.kak/rc/plug.kak"
set-option global plug_always_ensure true
set-option global ui_options ncurses_assistant=off ncurses_set_title=false

add-highlighter global/ number-lines #-hlcursor
add-highlighter global/ show-matching
add-highlighter global/ regex '\h+$' 0:Error # show trailing whitespace as an error

colorscheme base16

eval %sh{kak-lsp --kakoune -s $kak_session}
set-option global lsp_server_configuration rust.clippy_preference=on
map global user l ':enter-user-mode lsp<ret>' -docstring 'enter lsp user mode'
hook global WinSetOption filetype=(rust|python|go) %{lsp-enable-window}

set-face global DiagnosticError default+u
set-face global DiagnosticWarning default+u

plug "jdugan6240/powerline.kak" defer powerline %{
    powerline-theme base16
} config %{
    powerline-start
}
plug "lePerdu/kakboard" config %{
    hook global WinCreate .* %{kakboard-enable}
}

hook global WinCreate ^[^*]+$ %{git show-diff}
hook global BufWritePost ^[^*]+$ %{git show-diff}

hook global WinCreate ^[^*]+$ %{editorconfig-load}

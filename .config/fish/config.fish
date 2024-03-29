# TODO: figure out gem path entries (are some of them used on the mac?)

export _JAVA_AWT_WM_NONREPARENTING=1

if test -z "$DISPLAY" -a -z "$TMUX"
    if test -n "$SSH_CONNECTION" -o -f /.dockerenv
        if status --is-interactive
            exec tmux
        end
    else if test -n "$TERMUX_VERSION"
        if status --is-interactive
            cat ~/.cache/wal/sequences
            exec tmux
        end
        # else if test -n "$XDG_VTNR" -a "$XDG_VTNR" -eq 1
        #     exec startx
    else if test -z "$WAYLAND_DISPLAY" && command -v sway &>/dev/null
        exec sway --unsupported-gpu
    end
end

if test (uname) = Darwin
    set -g fish_user_paths "/usr/local/opt/arm-gcc-bin@8/bin" $fish_user_paths
end
set -g fish_user_paths "$HOME/.scripts" $fish_user_paths
set -g fish_user_paths "$HOME/.local/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.gem/ruby/2.7.0/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.npm-global/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.pnpm-global/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.dotnet/tools" $fish_user_paths
set -g fish_user_paths "$HOME/.local/share/gem/ruby/3.0.0/bin" $fish_user_paths
set -x GOPATH "$HOME/.go"
if test -d "$HOME/.go/bin"
    set -g fish_user_paths "$HOME/.go/bin" $fish_user_paths
end
if test -d /opt/android-sdk/cmdline-tools/latest/bin
    set -g fish_user_paths /opt/android-sdk/cmdline-tools/latest/bin $fish_user_paths
end
if test -d /opt/flutter/bin
    set -g fish_user_paths /opt/flutter/bin $fish_user_paths
end
export PATH=(string replace -r '/usr/lib/jvm/java\-[^:]+:' '' "$PATH")
if test -d /usr/lib/jvm/default
    export JAVA_HOME=/usr/lib/jvm/default
end
export PATH="$PATH:$JAVA_HOME/bin"
export ANDROID_SDK_ROOT=$HOME/.android/Sdk

set fish_greeting

if command -v trash &>/dev/null
    abbr rm trash
    alias rm trash

    function mv --wraps mv
        if test (count $argv) -ge 2 -a ! -d "$argv[-1]"
            trash "$argv[-1]" 2>/dev/null
        end
        command mv $argv
    end
end

if command -v trash-restore &>/dev/null
    # Credit for this one-liner goes to @norcalli here: https://github.com/andreafrancia/trash-cli/issues/107#issuecomment-479241828
    alias trash-undo "echo '' | trash-restore 2>/dev/null | sed '\$d' | sort -k2,3 -k1,1n | awk 'END {print \$1}' | trash-restore >/dev/null 2>&1"
end

abbr zth "zathura --fork"
alias zth "zathura --fork"

alias R "R --quiet --save"

function python
    # Intelligently determines which startup silencing method to use by testing paths of python instances
    if test (command -v python2) -a (realpath (command -v python)) = (realpath (command -v python2))
        python2 $argv
    else if test (command -v python3) -a (realpath (command -v python)) = (realpath (command -v python3))
        python3 $argv
    else
        eval (command -v python) $argv
    end
end
function python2
    if test -z "$argv"
        eval (command -v python2) -i -c "''"
    else
        eval (command -v python2) $argv
    end
end
alias python3 "python3 -q"

alias ls "exa -a --icons --group-directories-first"
alias lsd "exa -al --icons --group-directories-first"
alias lst "exa -aT -L 5 --icons --group-directories-first"
alias lsta "exa -aT --icons --group-directories-first"

abbr tm taskmatter
alias tm taskmatter

alias nsxiv "nsxiv -a"

abbr hi himalaya
alias hi himalaya
abbr ihi "nvim +'Himalaya'"
alias ihi "nvim +'Himalaya'"

abbr dc "docker compose"
abbr dcu "docker compose up -d --remove-orphans"
abbr dcd "docker compose down --remove-orphans"
abbr dcdu "docker compose -f docker-compose-dev.yaml up --remove-orphans"
abbr dcdd "docker compose -f docker-compose-dev.yaml down --remove-orphans"

abbr pcp "rsync -r --info=progress2"
alias pcp "rsync -r --info=progress2"

abbr dot "git --git-dir ~/.dotfiles --work-tree ~"
alias dot "git --git-dir ~/.dotfiles --work-tree ~"

if test (uname) = Darwin
    abbr copy pbcopy
    alias copy pbcopy
    abbr paste pbpaste
    alias paste pbpaste
else if test -n "$WAYLAND_DISPLAY"
    abbr copy wl-copy
    alias copy wl-copy
    abbr paste wl-paste
    alias paste wl-paste
else
    abbr copy "xclip -selection clipboard -in"
    alias copy "xclip -selection clipboard -in"
    abbr paste "xclip -selection clipboard -out"
    alias paste "xclip -selection clipboard -out"
end

function gce
    set tmp (mktemp)
    gcc -Wall -o "$tmp" "$argv[1]" && "$tmp" $argv[2..]
end

function gde
    set tmp (mktemp)
    gcc -Wall -g -o "$tmp" $argv && gdb --quiet --args "$tmp" $argv
end

function gve
    set tmp (mktemp)
    gcc -Wall -g -o "$tmp" $argv && valgrind "$tmp" $argv
end

function music
    if tmux has-session -t music &>/dev/null
        tmux attach -t music
    else
        tmux new-session -d -s music -c ~/music fish -C "mpv --shuffle --loop-playlist --no-audio-display --volume=40 --input-ipc-server=/tmp/mpv-socket ."
    end
end

abbr g git
alias g git

export EDITOR=kak
# export EDITOR=nvim
export VISUAL="$EDITOR"
abbr e "$EDITOR"
alias e "$EDITOR"
alias nvim "nvim -w ~/.local/share/nvim/keylog"
if command -v sudoedit &>/dev/null
    abbr se sudoedit
    alias se sudoedit
end
if command -v bat &>/dev/null
    export PAGER="bat --plain"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
end
source $HOME/.config/lf/icons

if status is-interactive
    if test -f ~/.config/tabtab/fish/__tabtab.fish
        source ~/.config/tabtab/fish/__tabtab.fish
    end
    
    fish_vi_key_bindings

    # TODO: make pasting work in visual mode
    # TODO: make d and x keys work with this
    bind -s p 'commandline -C (math (commandline -C) + 1); fish_clipboard_paste; commandline -f backward-char repaint-mode'
    bind -s P 'fish_clipboard_paste; commandline -f repaint-mode'
    bind -s -M visual -m default y 'fish_clipboard_copy; commandline -f swap-selection-start-stop end-selection repaint-mode'

    bind -s -M visual e forward-single-char forward-word backward-char
    bind -s -M visual E forward-bigword backward-char

    # bind -s -M normal V beginning-of-line begin-selection end-of-line
    # bind -s -M normal yy 'commandline -f kill-whole-line; fish_clipboard_copy'

    bind -s -M insert \cf 'set old_tty (stty -g); stty sane; lfcd; stty $old_tty; commandline -f repaint'

    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore

    set -U fish_color_autosuggestion brblack
    set -U fish_color_cancel -r
    set -U fish_color_command brgreen
    set -U fish_color_comment brmagenta
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_end brmagenta
    set -U fish_color_error brred
    set -U fish_color_escape brcyan
    set -U fish_color_history_current --bold
    set -U fish_color_host normal
    set -U fish_color_match --background=brblue
    set -U fish_color_normal normal
    set -U fish_color_operator cyan
    set -U fish_color_param brblue
    set -U fish_color_quote yellow
    set -U fish_color_redirection bryellow
    set -U fish_color_search_match bryellow '--background=brblack'
    set -U fish_color_selection white --bold '--background=brblack'
    set -U fish_color_status red
    set -U fish_color_user brgreen
    set -U fish_color_valid_path --underline
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description yellow
    set -U fish_pager_color_prefix white --bold --underline
    set -U fish_pager_color_progress brwhite '--background=cyan'

    if test "$TERM_PROGRAM" = kitty
        alias ssh="TERM=xterm-256color command ssh"
    end

    if test -z "$SSH_CONNECTION" -a -z "$TMUX"
        cat ~/.cache/wal/sequences
    end

    if command -v starship &>/dev/null
        starship init fish | source
    end
end

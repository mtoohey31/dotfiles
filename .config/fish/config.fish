if test -z "$DISPLAY" -a -z "$TMUX"
    if test -n "$SSH_CONNECTION"
        if status --is-interactive
            exec tmux
        end
    else if test -n "$XDG_VTNR" -a "$XDG_VTNR" -eq 1
        export _JAVA_AWT_WM_NONREPARENTING=1
        exec startx
    end
end

if test (uname) = "Darwin"
    set -g fish_user_paths "/usr/local/opt/arm-gcc-bin@8/bin" $fish_user_paths
end
set -g fish_user_paths "$HOME/.scripts" $fish_user_paths
set -g fish_user_paths "$HOME/.local/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.gem/ruby/2.7.0/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.npm-global/" $fish_user_paths
set -g fish_user_paths "$HOME/.pnpm-global/bin/" $fish_user_paths

# TODO: Remove this temporary export
set -g fish_user_paths "$HOME/taskmatter" $fish_user_paths

abbr tm "taskmatter"
alias tm "taskmatter"

set -x GOPATH "$HOME/.go"

if test -d $HOME/.go/bin
    set -g fish_user_paths "$HOME/.go/bin" $fish_user_paths
end

if test -d /opt/android-sdk/cmdline-tools/latest/bin
    set -g fish_user_paths "/opt/android-sdk/cmdline-tools/latest/bin" $fish_user_paths
end

abbr dcu "docker-compose --env-file docker-compose.env up -d --remove-orphans"
abbr dcd "docker-compose --env-file docker-compose.env down --remove-orphans"

abbr pcp "rsync -r --info=progress2"
alias pcp "rsync -r --info=progress2"

if test $hostname = "rpimanjaro"
    abbr self "git --git-dir=\$HOME/.selfhosting --work-tree=\$HOME"
    alias self "git --git-dir=\$HOME/.selfhosting --work-tree=\$HOME"
end

abbr dot "git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME"
alias dot "git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME"

if which trash &> /dev/null
    abbr rm "trash"
    alias rm "trash"
end

if which trash-restore &> /dev/null
    # Credit for this one-liner goes to @norcalli here: https://github.com/andreafrancia/trash-cli/issues/107#issuecomment-479241828
    alias trash-undo "echo '' | trash-restore 2>/dev/null | sed '\$d' | sort -k2,3 -k1,1n | awk 'END {print \$1}' | trash-restore >/dev/null 2>&1"
end

abbr v "nvim"
abbr nv "nvim"
alias vi "nvim"
alias vim "nvim"

function sc
    sc-im $argv
    cat $HOME/.cache/wal/sequences
end

abbr zth "zathura --fork"
alias zth "zathura --fork"

alias R "R --quiet --no-save"

function python
    # Intelligently determines which startup silencing method to use by testing paths of python instances
    if test (which python2) -a (realpath (which python)) = (realpath (which python2))
        python2 $argv
    else if test (which python3) -a (realpath (which python)) = (realpath (which python3))
        python3 $argv
    else
        eval (which python) $argv
    end
end
function python2
    if test -z "$argv"
        eval (which python2) -i -c "''"
    else
        eval (which python2) $argv
    end
end
alias python3 "python3 -q"

if test -d $HOME/.termux
    alias ls "exa -a --group-directories-first"
    alias lsd "exa -al --group-directories-first"
    alias lst "exa -aT -L 5 --group-directories-first"
    alias lsta "exa -aT --group-directories-first"
else if not string match -rq ".*ish.*" (uname -r)
    alias ls "exa -a --icons --group-directories-first"
    alias lsd "exa -al --icons --group-directories-first"
    alias lst "exa -aT -L 5 --icons --group-directories-first"
    alias lsta "exa -aT --icons --group-directories-first"
end

function prompt
    while read cmd -S -c "$argv " -p fish_prompt -R fish_right_prompt
        eval $cmd
    end
end

abbr pg "git status; prompt git"
alias pg "git status; prompt git"

if test (uname) = "Darwin"
    abbr copy "pbcopy"
    alias copy "pbcopy"
    abbr paste "pbpaste"
    alias paste "pbpaste"
else
    abbr copy "xclip -selection clipboard -in"
    alias copy "xclip -selection clipboard -in"
    abbr paste "xclip -selection clipboard -out"
    alias paste "xclip -selection clipboard -out"
end

fish_vi_key_bindings

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

export VISUAL=nvim
export EDITOR=nvim

if status --is-interactive
    source $HOME/.config/lf/icons

    set -U fish_color_autosuggestion      brblack
    set -U fish_color_cancel              -r
    set -U fish_color_command             brgreen
    set -U fish_color_comment             brmagenta
    set -U fish_color_cwd                 green
    set -U fish_color_cwd_root            red
    set -U fish_color_end                 brmagenta
    set -U fish_color_error               brred
    set -U fish_color_escape              brcyan
    set -U fish_color_history_current     --bold
    set -U fish_color_host                normal
    set -U fish_color_match               --background=brblue
    set -U fish_color_normal              normal
    set -U fish_color_operator            cyan
    set -U fish_color_param               brblue
    set -U fish_color_quote               yellow
    set -U fish_color_redirection         bryellow
    set -U fish_color_search_match        'bryellow' '--background=brblack'
    set -U fish_color_selection           'white' '--bold' '--background=brblack'
    set -U fish_color_status              red
    set -U fish_color_user                brgreen
    set -U fish_color_valid_path          --underline
    set -U fish_pager_color_completion    normal
    set -U fish_pager_color_description   yellow
    set -U fish_pager_color_prefix        'white' '--bold' '--underline'
    set -U fish_pager_color_progress      'brwhite' '--background=cyan'

    if test -z "$SSH_CONNECTION" -a "$TERM_PROGRAM" = "alacritty" -a (uname) = "Darwin"
        $HOME/.scripts/alacritty-color-export/script.sh > /dev/null
    else if test -z "$SSH_CONNECTION"
        cat ~/.cache/wal/sequences
    end

    if which starship &> /dev/null
        starship init fish | source
    end
end

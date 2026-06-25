#!/usr/bin/env bash
iatest=$(expr index "$-" i)
#==============================================================================
#  ███╗   ███╗ █████╗  ██╗  ██╗███████╗███████╗██╗    ██╗ █████╗  ██████╗  █████╗   ██████╗  ██████╗  ██████╗ 
#  ████╗ ████║██╔══██╗ ██║  ██║██╔════╝██╔════╝██║    ██║██╔══██╗ ██╔══██╗██╔══██╗ ██╔════╝ ██╔════╝ ██╔═══██╗
#  ██╔████╔██║███████║ ███████║█████╗  ███████╗██║ █╗ ██║███████║ ██████╔╝███████║ ███████╗ ███████╗ ██║██╗██║
#  ██║╚██╔╝██║██╔══██║ ██╔══██║██╔══╝  ╚════██║██║███╗██║██╔══██║ ██╔══██╗██╔══██║ ██╔═══██╗██╔═══██╗██║╚████║
#  ██║ ╚═╝ ██║██║  ██║ ██║  ██║███████╗███████║╚███╔███╔╝██║  ██║ ██║  ██║██║  ██║ ╚██████╔╝╚██████╔╝╚██████╔╝
#  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═╝  ╚═╝╚══════╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═════╝  ╚═════╝  ╚═════╝ 
#
#                                ██████╗  █████╗  ███████╗██╗  ██╗
#                                ██╔══██╗██╔══██╗ ██╔════╝██║  ██║
#                                ██████╔╝███████║ ███████╗███████║
#                                ██╔══██╗██╔══██║ ╚════██║██╔══██║
#                                ██████╔╝██║  ██║ ███████║██║  ██║
#                                ╚═════╝ ╚═╝  ╚═╝ ╚══════╝╚═╝  ╚═╝
#==============================================================================


# If not running interactively, don't do anything
[[ $- != *i* ]] && return
source ~/.local/share/blesh/ble.sh --attach=none

# ================================= fastfetch ================================= #
if command -v fastfetch &> /dev/null; then
    if [[ -d "$HOME/.local/share/fastfetch" ]]; then
        export ffconfig=minimal
        fastfetch --config "$ffconfig"
        alias fastfetch='clr && fastfetch --config "$ffconfig"'
    else
        fastfetch
    fi
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ================================= prompt ================================= #
PS1='\n\[\e[38;5;238m\]╭ \[\e[1;34m\]$(if [[ "$PWD" == "$HOME" ]]; then echo -n ""; elif [[ "$PWD" == "/" ]]; then echo -n ""; else echo -n ""; fi)  \w\[\e[0m\]\n\[\e[38;5;238m\]╰ \[\e[1;32m\]❯\[\e[0m\] '

# set prompt starship
# export STARSHIP_CONFIG=$HOME/.bash/starship/starship-macos_frame.toml

# Cache starship init to speed up terminal start
STARSHIP_CACHE="$HOME/.cache/starship_init.bash"
if [[ ! -s "$STARSHIP_CACHE" || "$(command -v starship)" -nt "$STARSHIP_CACHE" ]]; then
    mkdir -p "$(dirname "$STARSHIP_CACHE")"
    starship init bash > "$STARSHIP_CACHE"
fi
# source "$STARSHIP_CACHE"


# User specific environment
for p in "$HOME/.local/bin" "$HOME/bin" "$HOME/.opencode/bin"; do
    if [[ ":$PATH:" != *":$p:"* ]] && [[ -d "$p" ]]; then
        export PATH="$p:$PATH"
    fi
done

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head 200; else bat -n --color=always --line-range :1000 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"



# ================================= fzf ================================= #
if [[ -x "$(command -v fzf)" ]]; then
	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --info=inline-right \
	  --ansi \
	  --layout=reverse \
	  --border=rounded \
	  --color=border:#27a1b9 \
	  --color=fg:#c0caf5 \
	  --color=gutter:#16161e \
	  --color=header:#ff9e64 \
	  --color=hl+:#2ac3de \
	  --color=hl:#2ac3de \
	  --color=info:#545c7e \
	  --color=marker:#ff007c \
	  --color=pointer:#ff007c \
	  --color=prompt:#2ac3de \
	  --color=query:#c0caf5:regular \
	  --color=scrollbar:#27a1b9 \
	  --color=separator:#ff9e64 \
	  --color=spinner:#ff007c \
	"
fi

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Configure FZF for directory preview
if command -v fzf &> /dev/null; then
  _fzf_preview() {
    eza --color=always --icons=always "$1"
  }
fi


# ================================= completion and autocd ================================= #
bind "set completion-ignore-case on"
shopt -s autocd
unset rc



# ================================= add functionalities ================================= #
# Only load `thefuck` and `zoxide` when needed
_thefuck_init() { eval "$(thefuck --alias)"; unset -f _thefuck_init; }

alias fuck='_thefuck_init && fuck'
alias hell='_thefuck_init && hell'

# For zoxide integration with FZF (if zoxide is installed)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash --cmd cd)"
    alias zi='zoxide query -i | xargs -r eza --color=always --icons=always'
    _ZO_DOCTOR=0
fi

# ================================= source functions, aliases and blers ================================= #
source ~/.bash/functions.sh
source ~/.bash/alias.sh
source ~/.bash/.blerc



# ================================= Expand the history size ================================= #
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T" # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND="history -a; precmd"
alias hist="history | grep"


# ================================= transient prompt and right prompt ================================= #
bleopt prompt_ps1_transient=always
bleopt prompt_ps1_final="❯ "

# bleopt prompt_rps1='\n$(current_time)'
bleopt prompt_rps1='\n$(git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo $(git_info) || echo "")${elapsed_time_display}'


# ================================= vi mode ================================= #
bind 'set editing-mode vi'
bleopt keymap_vi_mode_show:=
bind "set show-mode-in-prompt on"
bind "set vi-cmd-mode-string "
bind "set vi-ins-mode-string "


# ================================= ble-attach ================================= #
[[ ${BLE_VERSION-} ]] && ble-attach
source "$HOME/.cargo/env"

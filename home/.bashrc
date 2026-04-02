#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$PATH"

alias composer='php81 /usr/bin/composer'
alias php='php81'

# tty-clock (gruvbox yellow, centered, bold, with seconds and date)
alias clock='tty-clock -c -b -s -t -C 3 -f "%A, %B %d"'

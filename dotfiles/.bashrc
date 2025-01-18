#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

#-------------------------------------------------------------------------------
# Everything above this line is the default .bashrc installed by archinstall
# Add customizations to the .bashrc_curtains file.
#-------------------------------------------------------------------------------
source $HOME/.bashrc_curtains



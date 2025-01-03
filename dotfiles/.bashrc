#
# .bashrc
#
#
# The contents of the first part of this file are exactly as they appear in the .bashrc that gets installed with archinstall.
# The only difference is the addition of the "Add Customizations" section at the bottom.
# To customize this setup, please make your changes in the ~/.bashrc_custom file so that we preserve the original .bashrc as it was installed by archinstall.
###################################################################33333#######

# If not running interactivley, don't do anything
[[ $- != *i* ]] && return

alias ls="ls --color=auto"
alias grep="grep --color=auto"

PS1='[\u@\h \W]\$ '

#----------------------------------------------------
# Add Customizations
#----------------------------------------------------
source $HOME/.bashrc_curtains
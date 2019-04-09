fpath=($fpath ~/.zsh/functions)

# load zgen
source "${HOME}/.zgen/zgen.zsh"

# if the init script doesn't exist
if ! zgen saved; then

  # specify plugins here
  zgen oh-my-zsh
  zgen load miekg/lean
  zgen oh-my-zsh plugins/git


  # generate the init script from plugins above
  zgen save
fi

#autoload -U promptinit && promptinit
PROMPT_LEAN_VIMODE=1
# jobs and vcs color
PROMPT_LEAN_COLOR1=132
# prompt char and directory
PROMPT_LEAN_COLOR2=214 

set -o vi
##############################################################################
# History Configuration
##############################################################################
HISTSIZE=5000               #How many lines of history to keep in memory
HISTFILE=~/.zsh_history     #Where to save history to disk
SAVEHIST=5000               #Number of history entries to save to disk
#HISTDUP=erase              #Erase duplicates in the history file
setopt    appendhistory     #Append history to the history file (no overwriting)
setopt    sharehistory      #Share history across terminals
setopt    incappendhistory  #Immediately append to the history file, not just when a term is killed


# reduces delay to 0.1seconds
export KEYTIMEOUT=1


alias k=kubectl
alias vi=vim
alias t=tmux
alias g=git
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

export PHONE_HOME=/data/data/com.termux/files/home
export PATH=$PATH:$HOME/bazel-go/bin/

# better searching in cmd mode
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward

# Beginning search with arrow keys
autoload up-line-or-beginning-search
autoload down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search


export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export GOPATH=$HOME/g
export PATH=$PATH:$HOME/.local/bin/:$GOPATH/bin/


b() {
	case "$1" in
		(b|build) shift
			command bazel build "$@" ;;
		(r|run) shift
			command bazel run -- "$@" ;;
		(t|test) shift
			command bazel test "$@" ;;
		(c|clean) shift
			command bazel clean "$@" ;;
		(e|expunge) shift
			command bazel clean --expunge "$@" ;;
		(i|info) shift
			command bazel info "$@" ;;
		(q|query) shift
			command bazel query "$@" ;;
		(s|sync) shift
			command bazel sync "$@" ;;
		(*) command bazel "$@" ;;
	esac
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# Virtualenvwrapper things
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/bin/virtualenvwrapper.sh

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

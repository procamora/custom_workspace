#
# Functions
#

# The name of the current branch
# Back-compatibility wrapper for when this function was defined here in
# the plugin, before being pulled in to core lib/git.zsh as git_current_branch()
# to fix the core -> git plugin dependency.
function current_branch() {
  git_current_branch
}

# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}

#
# Aliases
# (sorted alphabetically)
#

alias g='git'

alias ga='git add'

alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbda='git branch --no-color --merged | command grep -vE "^(\+|\*|\s*($(git_main_branch)|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'

alias gc='git commit -v'
alias gcs='git commit -S'
alias gcm='git commit -m'

alias gcb='git checkout -b'
alias gco='git checkout'

alias gcl='git clone --recurse-submodules'



alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

alias gd='git diff'
alias gdw='git diff --word-diff'

alias gf='git fetch origin'
alias gfa='git fetch --all --prune --jobs=10'

alias gl='git pull origin "$(git_current_branch)"'

alias glg='git log --graph --decorate --all'
alias glgp="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias glo='git log --oneline --decorate --graph'

alias gm='git merge'
alias gmom='git merge origin/$(git_main_branch)'
alias gmt='git mergetool --no-prompt'
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/$(git_main_branch)'
alias gma='git merge --abort'

alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias ggpush='git push origin "$(git_current_branch)"'
alias gpu='git push upstream'
alias gpv='git push -v'

alias gr='git remote'

alias grb='git rebase'

alias grev='git revert'

alias grh='git reset'
alias grhh='git reset --hard'
alias groh='git reset origin/$(git_current_branch) --hard'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

alias gsb='git status -sb'
alias gs='git status'

alias gsps='git show --pretty=short --show-signature'

alias gsi='git submodule init'
alias gsu='git submodule update'

alias gts='git tag -s'
alias gtv='git tag | sort -V'


alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'

function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

unset git_version

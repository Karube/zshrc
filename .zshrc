# LANGの設定
export LANG=ja_JP.UTF-8
# PATHの設定
export EDITOR='emacs'
export PATH=$PATH:~/flex_sdk/bin

# Emacs style key binding
bindkey -e

# putty use home / end
bindkey "^[[3~" delete-char
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# エスケープシーケンスを使う。
setopt prompt_subst

    PROMPT="%{[33m%}[%*] %{[32m%}$LOGNAME@${HOST%%.*}:%{[31m%}%~%%%{[m%} "
    PROMPT2="%{[31m%}%_%%%{[m%} "
    SPROMPT="%{[31m%}%r is correct? [n,y,a,e]:%{[m%} "

# ブランチ名の表示
# autoload -Uz vcs_info
# zstyle ':vcs_info:*' formats '(%s)-[%b]'
# zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
# precmd () {
#     psvar=()
#     LANG=en_US.UTF-8 vcs_info
#     [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
# }

#  RPROMPT="%1(v|%F{green}%1v%f|)"

# autoload -Uz is-at-least
# if  is-at-least 4.3.10; then
#     autoload -Uz vcs_info
#     autoload colors; colors
#     zstyle ':vcs_info:(git|svn):*' formats '%R' '%S' '%b'
#     zstyle ':vcs_info:(git|svn):*' actionformats '%R' '%S' '%b|%a'
#     zstyle ':vcs_info:*' formats '%R' '%S' '%s:%b'
#     zstyle ':vcs_info:*' actionformats '%R' '%S' '%s:%b|%a'
#     precmd_vcs_info () {
#         psvar=()
#         LANG=en_US.UTF-8 vcs_info
#         repos=`print -nD "$vcs_info_msg_0_"`
#         [[ -n "$repos" ]] && psvar[2]="$repos"
#         [[ -n "$vcs_info_msg_1_" ]] && psvar[3]="$vcs_info_msg_1_"
#         [[ -n "$vcs_info_msg_2_" ]] && psvar[1]="$vcs_info_msg_2_"
#     }
#     typeset -ga precmd_functions
#     precmd_functions+=precmd_vcs_info

#     local dirs='[%F{yellow}%3(v|%32<..<%3v%<<|%60<..<%~%<<)%f]'
#     local vcs='%3(v|[%25<\<<%F{yellow}%1v%f%<<]|)'
#     RPROMPT="$vcs"
# fi

setopt prompt_subst
autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

function rprompt-git-current-branch {
  local name st color gitdir action
  if [[ "$PWD" =~ '/¥.git(/.*)?$' ]]; then
    return
  fi
  name=$(basename "`git symbolic-ref HEAD 2> /dev/null`")
  if [[ -z $name ]]; then
    return
  fi

  gitdir=`git rev-parse --git-dir 2> /dev/null`
  action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    color=%F{green}
  elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
    color=%F{yellow}
  elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
    color=%B%F{red}
  else
     color=%F{red}
  fi
  echo "[$color$name$action%f%b] "
}

# -------------- 使い方 ---------------- #
RPROMPT='`rprompt-git-current-branch`'


# terminal
case "${TERM}" in
kterm*|xterm)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

# function ssh_screen(){
#  eval server=\${$#}
#  screen -t $server ssh "$@"
# }

function ssh_screen(){
 eval server=\${$#}
 tmux rename $server ssh "$@"
}

# if [ x$TERM = xscreen ]; then
#     alias ssh=ssh_screen
# fi

if [ "$TERM" = "screen" ]; then
    chpwd () { echo -n "_`dirs`\\" }
    preexec() {
        emulate -L zsh
        local -a cmd;
        cmd=(${(z)2})
        case $cmd[1] in
            fg)
                if (( $#cmd == 1 )); then
                    cmd=(builtin jobs -l %+)
                else
                    cmd=(builtin jobs -l $cmd[2])
                fi
                ;;
            %*)
                cmd=(builtin jobs -l $cmd[1])
                ;;
            cd)
                if (( $#cmd == 2)); then
                    cmd[1]=$cmd[2]
                fi
                ;&
            sudo)
                if (( $#cmd >= 2)); then
                    cmd[1]=$cmd[2]
                fi
                ;&
            *)
               echo -n "k$cmd[1]:t\\"
               return
               ;;
         esac

    local -A jt; jt=(${(kv)jobtexts})

    $cmd >>(read num rest
        cmd=(${(z)${(e):-\$jt$num}})
        echo -n "k$cmd[1]:t\\") 2>/dev/null
    }
    chpwd
fi

# if [ "$TERM" = "screen" ]; then
#     precmd(){
#         screen -X title $(basename $(print -P "%~"))
#         echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
#     }
#fi

 if [ "$TERM" = "screen" ]; then
    precmd(){
        tmux renamew $(basename $(print -P "%~"))
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
fi

HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000

# デフォルトの補完機能を有効
autoload -U compinit
compinit

# 先頭がスペースならヒストリーに追加しない。
 setopt hist_ignore_space

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加する
setopt append_history

# # リダイレクトで上書きする事を許可しない。
# setopt no_clobber

# ベルを鳴らさない。
setopt no_beep

# setopt no_tify

# 履歴ファイルに時刻を記録
setopt extended_history

# 履歴をインクリメンタルに追加
setopt inc_append_history

# 履歴の共有
setopt share_history

# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups

# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify

# dabbrev
HARDCOPYFILE=$HOME/tmp/screen-hardcopy
touch $HARDCOPYFILE

# dabbrev
HARDCOPYFILE=$HOME/tmp/screen-hardcopy
touch $HARDCOPYFILE

dabbrev-complete () {
        local reply lines=80 # 80行分
        screen -X eval "hardcopy -h $HARDCOPYFILE"
        reply=($(sed '/^$/d' $HARDCOPYFILE | sed '$ d' | tail -$lines))
        compadd - "${reply[@]%[*/=@|]}"
}

zle -C dabbrev-complete menu-complete dabbrev-complete
bindkey '^o' dabbrev-complete
bindkey '^o^_' reverse-menu-complete

### set alias
alias rr="rm -rf"
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

alias pd="pushd"
alias po="popd"
#alias cd="cd \!*; dirs"
alias gd='dirs -v; echo -n "select number: "; read newdir; cd +"$newdir"'

alias ls='ls'
alias ll='ls -l'
alias l='ls -lAG'
#alias la="ls -lhAF --color=auto"
#alias l='ls -lA --color=auto'
alias la="ls -lhAFG"
alias cl="make -f ~/Makefile clean"
# alias ps="ps -fU`whoami` --forest"

alias less='less -R'


#alias a2ps="a2psj"
#alias xdvi="xdvi-ja"
#alias xdvi="ssh -X -f paddy \xdvi"
if [ `uname` = "FreeBSD" ]
then
    alias xdvi="\xdvi -page a4 -s 0"
fi
#alias gs="gs-ja"
#alias jman="LANG=ja_JP.EUC \jman"

# alias mo="mozilla &"
# alias e="emacs &"
# alias enw="emacs -nw"

alias a="./a.out"
alias x="exit"
alias -g L='| lv -c'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
#alias -g W='| wc'
alias -g S='| sed'
#alias -g A='| awk'


# alias rd2ewb="rd2 -r rd/rd2ewb-lib"
# #alias rd2ewb "rd2 -r rd2ewb-lib"
# alias dpkg="env COLUMNS=130 \dpkg"

# alias mutt="env EDITOR=vim \mutt"

# alias sudo="env PATH=${PATH}:/sbin:/usr/sbin:/usr/local/sbin \sudo"

# #alias sodipodi="env GTK_IM_MODULE=im-ja \sodipodi"

# alias tgif="\tgif -dbim xim"

alias scr='screen -D -RR'

# Stop,Suspendをやめる
stty stop undef
stty susp undef
### end of file

# for tramp
if [[ $TERM == "dumb" ]]; then
    PROMPT="%n@%~%(!.#.$)"
    RPROMPT=""
    PS1='%(?..[%?])%!:%~%# '
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    unfunction precmd
    unfunction preexec
fi

# 履歴でのワイルドカード有効
if zle -la | grep -q '^history-incremental-pattern-search'; then
  # zsh 4.3.10 以降でのみ有効
  bindkey '^R' history-incremental-pattern-search-backward
  bindkey '^S' history-incremental-pattern-search-forward
fi

alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'
alias emacs_w ='/Applications/Emacs.app/Contents/MacOS/Emacs'

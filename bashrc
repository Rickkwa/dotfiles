# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias vmi='vim'

alias tarunzip='tar -xvzf'
alias tarzip='tar -zcvf'

alias yumall='yum list available --showduplicates'

# Disable CTRL+S terminal pause
stty -ixon

docker() {
    if [[ $1 == "in" ]]; then
        shift
        command docker exec -it $@ bash
    elif [[ $1 == "ip" ]]; then
        shift
        command docker inspect -f '{{.NetworkSettings.IPAddress}}' $1
    elif [[ $1 == "rme" ]]; then
        exited=`docker ps -a | grep Exit | cut -d ' ' -f 1`
        command docker rm $exited
    elif [[ $1 == "tail" ]]; then
        shift
        command docker logs -f $@
    elif [[ $1 == "down" ]]; then
        shift
        command docker stop $@
        command docker rm $@
    else
        command docker $@
    fi
}

tmux() {
    if [[ $1 == "go" ]]; then
        shift
        command tmux a -t $@
    else
        command tmux $@
    fi
}

# SSH agent
load-ssh-agent() {
    if ! $(ps aux | grep '/usr/bin/ssh-agent' > /dev/null); then
        ssh-agent -s > ~/.ssh-agent.sh;
        ssh-add -t 10h ~/.ssh/prod_id_rsa
        if [ $? -ne 0 ]; then ssh-agent -k; fi
    fi
    source ~/.ssh-agent.sh
}

ssh() {
    if ! ssh-add -l > /dev/null 2>&1; then
        load-ssh-agent
    fi
    command ssh $@
}

export PS1='\[\033[1;34m\][\A][\u@\h \W]\$\[\033[0m\] '
export TERM=cygwin
FIGNORE=".pyc:.retry"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

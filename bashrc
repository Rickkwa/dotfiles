# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias vmi='vim'

alias tarunzip='tar -xvzf'
alias tarzip='tar -zcvf'

alias yumall='yum list available --showduplicates'

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
        command docker stop $1
        command docker rm $1
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
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval `ssh-agent -s`
    ssh-add
    trap 'test -n "$SSH_AGENT_PID" && eval `/usr/bin/ssh-agent -k`' 0
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


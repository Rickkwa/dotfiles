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
ssh-reagent () {
    for agent in /tmp/ssh-*/agent.*; do
        export SSH_AUTH_SOCK=$agent
        if ssh-add -l 2>&1 > /dev/null; then
            echo Found working SSH Agent:
            ssh-add -l
            return
        else
            rm -f $agent
        fi
    done
    echo "Cannot find ssh agent - creating new one"
    eval `ssh-agent -s`
    ssh-add
}

ssh() {
    if ! ssh-add -l 2>&1 > /dev/null; then
        ssh-reagent
    fi
    command ssh $@
}

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


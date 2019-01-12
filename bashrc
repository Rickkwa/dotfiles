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
load-ssh-agent () {
    for agent in /tmp/ssh-*/agent.*; do
        export SSH_AUTH_SOCK=$agent
        if ssh-add -l > /dev/null 2>&1; then
            ssh-add -l
            return
        else
            rm -f "$agent"
        fi
    done
    eval `ssh-agent -s`
    ssh-add -t 12h
    if [ $? -ne 0 ]; then ssh-agent -k; fi
}

ssh() {
    if ! ssh-add -l > /dev/null 2>&1; then
        load-ssh-agent
    fi
    command ssh $@
}

ctmux {
    CONF=~/.commandMux.conf
    CMDS=$1
    if [ -z $CMDS ]; then
        cat /dev/null > $CONF
    elif [ ! -f $CMDS ]; then
        echo "Not a file: $CMDS"
        return
    else
        # get number of panes we will need to create
        PANES=`wc -l $CMDS | awk '{print $1}'`

        if [ $PANES -lt 1 ]; then
            cat /dev/null > $CONF
        else
            i=1 # manually count since last line treated differently
            echo "selectp -t 0" > $CONF

            while read line
            do
                echo "send-keys '$line' enter" >> $CONF
                MOD=`echo "$i % 4" | bc`
                if [ $MOD -eq 0 ]; then
                    echo "select-layout tiled" >> $CONF
                fi
                # only add panes if we aren't at the last one
                # new pane gets focus for next send-keys call
                if [ $i -lt $PANES ]; then
                    echo "splitw -h -p 50" >> $CONF # Add a new pane
                fi
                i=$(( i + 1 ))
            done < $CMDS
            # Adjust the layout to homogeneize the panes
            echo "select-layout tiled" >> $CONF
            # Come back to the original pane
            echo "selectp -t 0" >> $CONF
        fi
    fi
    /usr/bin/tmux;
}

export PS1='\[\033[1;34m\][\A][\u@\h \W]\$\[\033[0m\] '
export TERM=cygwin
FIGNORE=".pyc:.retry"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

### Configuration ###

OP_DIR="/home/deploy/install/nginx/vhost"

SERVER="deploy@101.37.14.72"
SCP_FROM_DIR="vhost"
SCP_TO_DIR="$OP_DIR/releases/$(date '+%s')" # use timestamps to version control

REMOTE_SERVER_RELOAD_SCRIPT="sudo nginx -c /home/deploy/install/nginx/nginx-LB-Dispatch.conf"

### private ###

# $1: the prefix this log will use as "[prefix] xxxx"
_use_red_green_echo() {
  prefix="$1"
  red() {
    echo "$(tput bold)$(tput setaf 1)[$prefix] $*$(tput sgr0)";
  }
  
  green() {
    echo "$(tput bold)$(tput setaf 2)[$prefix] $*$(tput sgr0)";
  }
  
  yellow() {
    echo "$(tput bold)$(tput setaf 3)[$prefix] $*$(tput sgr0)";
  }
}
_use_red_green_echo AUTO-DEPLOY

_run_local(){
  green "[Running] $@"
  "$@"
}

_run_remote(){
  _run_local ssh $SERVER $1 && green "Success!!!"
}

### public ###

deploy(){
  yellow "---- Deploying to remote server: $SERVER ----"
  # upload
  _run_local scp -r $SCP_FROM_DIR $SERVER:$SCP_TO_DIR && green "Success!!!"
  # cp to current
  _run_remote "cp -f $SCP_TO_DIR/* $OP_DIR/current"
}

remote_reload(){
  yellow "---- Running deployment script on remote server: $SERVER ----"
  _run_remote $REMOTE_SERVER_RELOAD_SCRIPT
}

### main ###

"$@"


# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

### Configuration ###

REMOTE_OP_DIR="/home/deploy/install/nginx"

SERVER="deploy@101.37.14.72"

MAIN_CONFIG_FILE="nginx-LB-Dispatch.conf"
VHOST_DIR="vhost"

VHOST_SCP_TO_DIR="$REMOTE_OP_DIR/$VHOST_DIR/releases/$(date '+%s')" # use timestamps to version control

REMOTE_SERVER_RELOAD_SCRIPT="sudo nginx -s reload -c $REMOTE_OP_DIR/$MAIN_CONFIG_FILE"

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

# $1: shell script
_run_local(){
  yellow "[Running] $@"
  "$@" && green "Success!!!"
}

# $1: shell script
_run_remote(){
  _run_local ssh $SERVER $1
}

### public ###

deploy(){
  green "---- Deploying to remote server: $SERVER ----"
  # upload main config
  _run_local scp $MAIN_CONFIG_FILE $SERVER:$MAIN_CONFIG_FILE_SCP_TO_DIR
  # upload vhost config
  _run_local scp -r $VHOST_DIR $SERVER:$VHOST_SCP_TO_DIR
  # cp to current
  _run_remote "mkdir -p $REMOTE_OP_DIR/$VHOST_DIR/current && cp -f $VHOST_SCP_TO_DIR/* $REMOTE_OP_DIR/$VHOST_DIR/current"
}

remote_reload(){
  green "---- Running deployment script on remote server: $SERVER ----"
  _run_remote "$REMOTE_SERVER_RELOAD_SCRIPT"
}

### main ###

"$@"


# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

### Configuration ###

SERVER="myappuser@yourserver.com"
SCP_FROM_DIR="TODO"
SCP_TO_DIR="TODO"

EXEC_SCRIPT_FILE="scripts/start-nginx.sh"

### methods ###

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

_run(){
  green "[yqj-lb-dispatcher-nginx] Running: $@"
  "$@"
}

deploy(){
  yellow "---- Deploying to remote server: $SERVER ----"
  # TODO
  # run scp -r $SCP_FROM_DIR $SERVER:$SCP_TO_DIR
  green
}

remote_reload(){
  yellow "---- Running deployment script on remote server: $SERVER ----"
  # TODO
  # run ssh $SERVER bash $EXEC_SCRIPT_FILE
  green "Success!!!"
}

### main ###

deploy
remote_reload



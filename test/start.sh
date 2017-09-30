# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_prepare(){
  mkdir -p logs
}

start(){
  
  # start
  if [[ ! -f "openresty.pid" ]]; then
    openresty -p `pwd` -c test-openresty.conf
    return
  else
    # reload
    openresty -p `pwd` -c test-openresty.conf -s reload
  fi
  
}

_prepare

start

# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_prepare(){
  rm -rf logs && mkdir -p logs
}

start(){
  if [[ ! -f "openresty.pid" ]]; then
    # start
    openresty -p `pwd`/test -c test-openresty.conf
    return
  else
    # reload
    openresty -p `pwd`/test -c test-openresty.conf -s reload
  fi
}

_prepare

start

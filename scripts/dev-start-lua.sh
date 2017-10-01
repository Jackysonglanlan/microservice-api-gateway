# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_cleanLogs(){
  local logFiles=(access error alert info)
  for file in ${logFiles[@]}; do
    echo '' > test/logs/$file.log
    echo '' > logs/$file.log
  done
}

_prepare(){
  _cleanLogs
}

start(){
  if [[ -f "test/openresty.pid" ]]; then
    return
  fi
  node ./node_modules/.bin/nodemon --exec "openresty -p `pwd`/test -c test-openresty.conf"
}

reload(){
  if [[ -f "test/openresty.pid" ]]; then
    kill $(cat test/openresty.pid)
  fi
  
  sleep 1 # wait to finish killing
  
  if [[ ! -f "test/openresty.pid" ]]; then
    openresty -p `pwd`/test -c test-openresty.conf
  fi
}

_prepare

$@

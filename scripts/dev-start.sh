# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_mkLogDirs(){
  mkdir -p {logs,'test/logs'}
}

_cleanLogs(){
  local logFiles=(access error alert info)
  for file in ${logFiles[@]}; do
    if [[ -f "test/logs/$file.log" ]]; then
      echo '' > test/logs/$file.log
    fi
    if [[ -f "logs/$file.log" ]]; then
      echo '' > logs/$file.log
    fi
  done
}

_prepare(){
  _mkLogDirs
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

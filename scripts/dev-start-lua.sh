# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_prepare(){
  echo '' > test/logs/access.log
  echo '' > test/logs/error.log
  echo '' > logs/access.log
  echo '' > logs/error.log
}

start(){
  if [[ ! -f "test/openresty.pid" ]]; then
    node ./node_modules/.bin/nodemon --exec "openresty -p `pwd`/test -c test-openresty.conf"
  fi
}

reload(){
  if [[ -f "test/openresty.pid" ]]; then
    kill $(cat test/openresty.pid)
    sleep 1
    start
  fi
}

_prepare

# dyna invoke
$@

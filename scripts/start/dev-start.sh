# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_mkLogDirs(){
  mkdir -p {logs,'test/logs','test/logs/nginx'}
  
  # those utils.log() log files can't be auto-created on mac (no idea why)
  touch logs/yqj.{debug,info,warn,error}.log
}

_cleanLogs(){
  local logDirs=(logs 'test/logs')
  for logDir in ${logDirs[@]}; do
    for logFile in $logDir/*.log; do
      if [[ -f $logFile ]]; then
        echo '' > $logFile
      fi
    done
  done
}

_prepare(){
  _mkLogDirs
  _cleanLogs
}

# public

start(){
  if [[ -f "test/openresty.pid" ]]; then
    echo "[WARN] Openresty is started, pid: `cat test/openresty.pid`"
    return
  fi
  ./node_modules/.bin/nodemon --exec "openresty -p `pwd`/test -c test-openresty.conf"
}

nodemon_restart(){
  if [[ -f "test/openresty.pid" ]]; then
    # cat test/openresty.pid
    kill `cat test/openresty.pid`
    sleep 1 # wait to finish killing
  fi
  
  sleep 1 # wait to finish killing
  
  if [[ ! -f "test/openresty.pid" ]]; then
    openresty -p `pwd`/test -c test-openresty.conf
  fi
}

# run

_prepare

LUA_ENV=dev $@

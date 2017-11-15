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

OPENRESTY_PID_FILE_PATH='logs/pids/openresty.pid'

start(){
  if [[ -f $OPENRESTY_PID_FILE_PATH ]]; then
    echo "[WARN] Openresty is started, pid: `cat $OPENRESTY_PID_FILE_PATH`"
    return
  fi
  ./node_modules/.bin/nodemon --exec "openresty -p `pwd`/test -c test-openresty.conf"
}

nodemon_restart(){
  if [[ -f $OPENRESTY_PID_FILE_PATH ]]; then
    # cat $OPENRESTY_PID_FILE_PATH
    kill "`cat $OPENRESTY_PID_FILE_PATH`"
    sleep 1 # wait to finish killing
  fi
  
  sleep 1 # wait to finish killing
  
  if [[ ! -f $OPENRESTY_PID_FILE_PATH ]]; then
    openresty -p `pwd`/test -c test-openresty.conf
  fi
}

# run

_prepare

LUA_ENV=dev $@

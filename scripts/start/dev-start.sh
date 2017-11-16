# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_mkLogDirs(){
  mkdir -p 'test/logs'
  
  # those utils.log() log files can't be auto-created on mac (no idea why)
  touch logs/yqj.{debug,info,warn,error}.log
}

_cleanLogs(){
  for logFile in $(find 'logs' -name '*.log') ; do
    # echo $logFile
    echo '' > $logFile
  done
}

_prepare(){
  _mkLogDirs
  _cleanLogs
}

OPENRESTY_PID_FILE_PATH='logs/pids/openresty.pid'

# public

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

# dynamic invoke public method
LUA_ENV=dev $@

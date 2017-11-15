# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

_unsetSoFilesCopiedMark(){
  PRESTART_PROCESS_DONE='./PRESTART-PROCESS-DONE.log'
  
  # make sure running prestart process on every new deployment
  echo "[YQJ] remove $PRESTART_PROCESS_DONE ..."
  rm -f $PRESTART_PROCESS_DONE
}

# 配置日志滚动记录
_config_logrotate(){
  local rotateFile='microservice-api-gateway-logrotate'
  sudo cp -f scripts/pm2-hooks/$rotateFile /etc/logrotate.d
  sudo chmod 644 /etc/logrotate.d/$rotateFile
  
  sleep 0.5
  
  # manually trigger the log rotation, it's ok if it fails
  /usr/sbin/logrotate -vdf /etc/logrotate.d/$rotateFile || echo ''
}


# ------

main(){
  _unsetSoFilesCopiedMark
  _config_logrotate
}

main

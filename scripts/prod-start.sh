# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# 这里，本来是在 npm hook: prestart 执行的
# 但是，由于在每次 pm2 部署完毕后，会自动启动，而这个动作是不会触发 prestart 的，所以这里加上
. scripts/build.sh

openresty -p `pwd`/test -c test-openresty.conf


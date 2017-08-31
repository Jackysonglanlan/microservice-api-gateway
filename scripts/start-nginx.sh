# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR


sudo nginx -c /home/deploy/install/nginx/nginx-LB-Dispatch.conf



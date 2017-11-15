# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

openresty -p `pwd`/test -c test-openresty.conf


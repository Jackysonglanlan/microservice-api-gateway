# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR


whichResult=$(which ${1:? Missing executable command as 1st param})
if [[ -L "$whichResult" ]]; then
  realPath=$(dirname $(readlink "$whichResult"))
  echo $realPath
else
  echo $(dirname "$whichResult")
fi


# Usage:
# path-finder lua

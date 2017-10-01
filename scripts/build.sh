# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

mac(){
  if [[ $(uname -a) == *Darwin* ]]; then
    "$@"
  fi
}

linux(){
  if [[ $(uname -a) == Linux* ]]; then
    "$@"
  fi
}

# $1: LIB_OPTION
build_lfs(){
  cd lua/libs/lfs
  make PREFIX=$LUA_HOME LIB_OPTION="$1" && make test && make install && make clean
}


# main

mac build_lfs "-bundle -undefined dynamic_lookup"
linux build_lfs "-shared"

# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

use_red_green_echo() {
  prefix="$1"
  red() {
    echo "$(tput bold)$(tput setaf 1)[$prefix] $*$(tput sgr0)";
  }
  
  green() {
    echo "$(tput bold)$(tput setaf 2)[$prefix] $*$(tput sgr0)";
  }
  
  yellow() {
    echo "$(tput bold)$(tput setaf 3)[$prefix] $*$(tput sgr0)";
  }
}
use_red_green_echo 'Build'


ALL_LIBS_BUILT_MARK_FILE='./all-libs-built.log'

_on_mac(){
  if [[ $(uname -a) == *Darwin* ]]; then
    yellow "[ON-MAC][SUB-SHELL] $@"
    ("$@")
  fi
}

_on_linux(){
  if [[ $(uname -a) == Linux* ]]; then
    yellow "[ON-LINUX][SUB-SHELL] $@"
    ("$@")
  fi
}

_markAllLibsAreBuilt(){
  green "All C libs are built..."
  green "Make mark file..."
  green "Done"
  touch $ALL_LIBS_BUILT_MARK_FILE
}

###### build all the C libs

# $1: LIB_OPTION
build_lfs(){
  cd lua/libs/lfs
  make LUA_LIB=$LUA_HOME LIB_OPTION="$1" && make test && make install && make clean && green Done
}

# $1: gcc param
build_cjson(){
  cd lua/libs/libcjson/cJSON
  gcc cJSON.c -O3 -o libcjson.so -shared ${1:-}
  mv libcjson.so ../.. # 必须放在 lua/libs 目录下(lua 库根目录)，否则 ffi_load 找不到
}

# ...

main(){
  if [[ -f $ALL_LIBS_BUILT_MARK_FILE ]]; then
    yellow 'All libs are built, no need to build...'
    return
  fi
  
  green 'Start building C libs...'
  
  _on_mac build_lfs "-bundle -undefined dynamic_lookup"
  _on_linux build_lfs "-shared"
  
  _on_mac build_cjson
  _on_linux build_cjson "-fPIC"
  
  _markAllLibsAreBuilt
}

main

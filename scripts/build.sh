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


ALL_BIN_FILES_COPIED_MARK_FILE='./all-bin-files-copied.log'

# lua lib root path
LUA_LIB_PATH="lua/libs"

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
  touch $ALL_BIN_FILES_COPIED_MARK_FILE
}

###### build all the C libs

# $1: LIB_OPTION
# build_lfs(){
#   cd lua/libs/lfs
#   make LUA_LIB=$LUA_HOME LIB_OPTION="$1" && make test && make install && make clean && green Done
# }
# _on_mac build_lfs "-bundle -undefined dynamic_lookup"
# _on_linux build_lfs "-shared"

# $1: gcc param
# build_cjson(){
#   cd lua/libs/libcjson/cJSON
#   gcc cJSON.c -O3 -o libcjson.so -shared ${1:-}
#   mv libcjson.so ../..
# }
# _on_mac build_cjson
# _on_linux build_cjson "-fPIC"

###### copy all the C libs to LUA_LIB_PATH
## Why:
## Compile those libs are tricky and boring, so we pre-build them to avoid the pain process in production Env.

# $1: mac or linux
_cp_all_bin_files_to_lua_root_path(){
  # 动态库 都必须放在 lua 库根目录，否则 ffi_load 找不到, 见 nginx 配置文件
  for soFile in $LUA_LIB_PATH/.prebuild/$1/*.so; do
    cp $soFile $LUA_LIB_PATH
  done
  
  # unzip tar.xz files
  for xzFile in $LUA_LIB_PATH/.prebuild/$1/*.tar.xz; do
    tar -Jxf $xzFile -C $LUA_LIB_PATH
  done
}

######

main(){
  if [[ -f $ALL_BIN_FILES_COPIED_MARK_FILE ]]; then
    yellow 'All libs are built, no need to build...'
    return
  fi
  
  green 'Start building C libs...'
  
  _on_mac _cp_all_bin_files_to_lua_root_path mac
  _on_linux _cp_all_bin_files_to_lua_root_path linux
  
  _markAllLibsAreBuilt
}

main

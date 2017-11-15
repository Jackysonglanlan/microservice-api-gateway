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


PRESTART_PROCESS_DONE='./PRESTART-PROCESS-DONE.log'

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

_markPrestartProcessDone(){
  green 'Mark prestart process done'
  touch $PRESTART_PROCESS_DONE
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
_cp_all_so_files_to_lua_root_path(){
  green 'Start copying .so libs...'
  
  # 动态库 都必须放在 lua 库根目录，否则 ffi_load 找不到, 见 nginx.conf 的 lua_package_cpath
  
  ##### WARN
  # 如果执行 require('luahs') 报错:
  #
  # 1. libstdc++.so.6 "GLIBCXX_3.4.20"
  # 请升级 gcc 到 5.5, 见 http://blog.csdn.net/gw85047034/article/details/52957516
  #
  # 注意事项:
  # make install 后可能需要:
  #   cd /usr/lib &&
  #   ln -sf /usr/local/lib64/libstdc++.so.6.0.21 /usr/local/lib64/libstdc++.{so,so.6}
  #
  # 升级后，执行 strings /path/to/libstdc++.so.6 | grep GLIBCXX
  # 看到 "GLIBCXX_3.4.20" 则 ok
  #
  # 2. libc.so.6 "GLIBC_2.14"
  # 请升级 glibc 到 2.14,  见 http://www.cnblogs.com/gw811/p/3676856.html
  # 注意事项同上
  #
  #####
  for soFile in $LUA_LIB_PATH/.prebuild/$1/*.so; do
    cp $soFile $LUA_LIB_PATH
  done
  
  # unzip tar.xz files
  for xzFile in $LUA_LIB_PATH/.prebuild/$1/*.tar.xz; do
    tar -Jxf $xzFile -C $LUA_LIB_PATH
  done
  
  green "All so libs are copied to lua lib path..."
}

_makeDirs(){
  green 'Making necessary dirs...'
  mkdir -p {tmp,'logs/nginx','logs/pm2'}
}

######

main(){
  if [[ -f $PRESTART_PROCESS_DONE ]]; then
    yellow 'Prestart process has been preformed, no need to run again...'
    return
  fi
  
  _on_mac _cp_all_so_files_to_lua_root_path mac
  _on_linux _cp_all_so_files_to_lua_root_path linux
  
  _makeDirs
  # TODO: more prestart steps add here
  
  _markPrestartProcessDone
}

main

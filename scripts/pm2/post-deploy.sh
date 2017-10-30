# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

ALL_SO_FILES_COPIED_MARK_FILE='all-so-files-copied.log'

# make sure copy *all* the so files on every new deployment
echo "[YQJ] remove all-so-files-copied.log ..."
rm -f $ALL_SO_FILES_COPIED_MARK_FILE

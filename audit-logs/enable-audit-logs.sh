#!/bin/bash

# Errors are fatal
set -e

# Change to this script's directory.
pushd $(dirname $0) > /dev/null

LOG="${PWD}/audit.log"

{
  set +e
  vault audit list
  RC=$?
  set -e
}

if test "$RC" -ne 0
then
  rm -rfv ${LOG}
  vault audit enable file file_path=${LOG}
  echo "# Audit logging now writing to ${LOG}"

else
  echo "# Audit log already enabled!  Skipping."

fi



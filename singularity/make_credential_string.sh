#!/bin/bash

set -e


USAGE=$(cat <<EOF
USAGE: ${0} user
password is read from STDIN
EOF
)

if [ -z "${AUTH_DIR}" ]
then
   echo "FATAL: env var AUTH_DIR not set" >&2
   exit 1
fi

if [ $# -ne 1 ]
then
   echo "${USAGE}" >&2
   exit 1
fi


user="${1}"
pw="$(cat)"

if [ "$(cat "${AUTH_DIR}/.salt" | wc -c)" -eq 0 ]
then
   #possible race condition but make_credential_string.sh is called for the first time from entrypoint which is executed before anything else
   for i in `seq 1 8`
   do
      printf "\x$(printf "%x" "$(( 65 + $RANDOM % 26 ))")" >> "${AUTH_DIR}/.salt"
   done
fi

echo "${user}:$(echo -n "${pw}" | mkpasswd -5 --salt="$(cat "${AUTH_DIR}/.salt")" --stdin)"

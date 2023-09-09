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

if [ $# -lt 1 ]
then
   echo "${USAGE}" >&2
   exit 1
fi


user_name="${1}"
pw="$(cat)"


diff <(echo -n "${pw}" | "${AUTH_DIR}/make_credential_string.sh" "${user_name}") "${AUTH_DIR}/.credential" > /dev/null

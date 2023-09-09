#!/bin/bash

trap 'kill -s STOP "${rstudio_server_pid}"' SIGTERM


export USER="$(whoami)"

if [ -z "${AUTH_DIR}" ]
then
   echo "FATAL: env var AUTH_DIR not set" >&2
   exit 1
fi

if [ -z "${RPASS}" ]
then
   echo "ERROR: environment variable RPASS not set" >&2
   exit 1
fi

if [ "$(id -u "${USER}")" -lt 1000 ]
then
   echo "ERROR: current user with a user id less than 1000 is considered a system user and thus not allowed to use rstudio-server" >&2
   exit 1
fi



echo "INFO: running as user ${USER}"
echo "INFO: use username ${USER} with the password supplied via RPASS to log into rstudio-server"

echo -n "${RPASS}" | "${AUTH_DIR}/make_credential_string.sh" "${USER}" > "${AUTH_DIR}/.credential"


/usr/lib/rstudio-server/bin/rserver \
   --server-daemonize=0 \
   --auth-timeout-minutes=0 \
   --auth-stay-signed-in-days=30 \
   --auth-none=0 \
   --auth-validate-user=0 \
   --server-user="${USER}" \
   --auth-pam-helper-path="${AUTH_DIR}/auth.sh" &

rstudio_server_pid=$!

wait

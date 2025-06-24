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


echo -n "${RPASS}" | "${AUTH_DIR}/make_credential_string.sh" "${USER}" > "${AUTH_DIR}/.credential"


listen_port=""
for p in `seq 8787 9000`
do
   if ! nc -z localhost ${p}-${p}
   then
      listen_port="${p}"
   fi
done

if [ -z "${listen_port}" ]
then
   echo "ERROR: couldn't find a free port" >&2
   exit 2
fi


/usr/lib/rstudio-server/bin/rserver \
   --server-daemonize=0 \
   --auth-timeout-minutes=0 \
   --auth-stay-signed-in-days=30 \
   --auth-none=0 \
   --auth-validate-user=0 \
   --auth-minimum-user-id=0 \
   --server-user="${USER}" \
   --auth-pam-helper-path="${AUTH_DIR}/auth.sh" \
   --www-port="${listen_port}" &

rstudio_server_pid=$!


echo "####################################################"
echo "INFO: running as user ${USER}"
echo "INFO: running on $(hostname -f)"
echo "INFO: listening on port ${listen_port}"
echo "INFO: use username ${USER} with the password supplied via RPASS to log into rstudio-server"


wait

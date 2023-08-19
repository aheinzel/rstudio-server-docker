#!/bin/bash

set -e

trap 'kill -s STOP "${rstudio_server_pid}"' SIGTERM

RSTUDIO_SERVER_DAEMON="/usr/lib/rstudio-server/bin/rserver"
INITIALIZED_MARKER="/initialized"

rstudio_server_args=("--server-daemonize" "0")
if [ "${1}" == "notimeout" ]
then
   rstudio_server_args+=("--auth-timeout-minutes" "0" "--auth-stay-signed-in-days" "30")
fi



if [ ! -f "${INITIALIZED_MARKER}" ]
then
   if [ -z "${RUSER}" ]
   then
      echo "reading users from STDIN" >&2
      RUSER="$(cat)"
   fi

   while read l
   do
      readarray -t ele < <(echo "${l}" | tr ":" "\n")
      args=("--shell" "/bin/bash")
      if [ "${#ele[@]}" -gt 2 ]
      then
         args+=("--uid" "${ele[0]}")
         ele=(${ele[@]:1})
      fi

      if [ "${#ele[@]}" -eq 3 ]
      then
         if ! getent group "${ele[0]}" &> /dev/null
         then
            groupadd --gid "${ele[0]}" "${ele[1]}"
         fi

         args+=("--gid" "${ele[0]}")
         ele=(${ele[@]:1})
      fi

      if [ "${#ele[@]}" -eq 2 ]
      then
         user_name="${ele[0]}"
         user_home="/home/${user_name}"
         args+=("${user_name}")
         if ! getent passwd "${user_name}" > /dev/null
         then
            useradd "${args[@]}"
            echo "${user_name}:${ele[1]}" | chpasswd
            if [ ! -d "${user_home}" ]
            then
               mkdir "${user_home}"
               chown "${user_name}:$(id -gn "${user_name}")" "${user_home}"
            fi
         fi
      else
         echo "invalid user string ${l}" >&2
         exit 1
      fi
   done < <(echo "${RUSER}")

   touch "${INITIALIZED_MARKER}"
fi

#complicated workaround to have rstudio-server terminate on SIGTERM
#when run with exec "${RSTUDIO_SERVER_DAEMON}" --server-daemonize 0 SIGTERM gets ignored
"${RSTUDIO_SERVER_DAEMON}" "${rstudio_server_args[@]}" &
rstudio_server_pid=$!

if ! kill -0 "${rstudio_server_pid}"
then
   echo "rstudio-server not running" >&2
   exit 1
fi

wait "${rstudio_server_pid}" || /bin/true

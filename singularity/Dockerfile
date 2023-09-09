FROM ah3inz3l/rstudio-server


RUN apt-get update && \
   apt-get -y install whois


RUN chmod 777 /var/lib/rstudio-server && \
   chmod 644 /etc/rstudio/database.conf


ENV AUTH_DIR=/var/lib/rstudio-server-auth

ADD auth.sh "${AUTH_DIR}/auth.sh"

ADD make_credential_string.sh "${AUTH_DIR}/make_credential_string.sh"

RUN touch "${AUTH_DIR}/.credential" "${AUTH_DIR}/.salt" && \
   chmod 666 "${AUTH_DIR}/.credential" "${AUTH_DIR}/.salt"


ADD entrypoint.sh /entrypoint.sh


EXPOSE 8787


ENTRYPOINT ["/entrypoint.sh"]

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


#add tidyverse to container
RUN apt-get update && \
   apt-get -y install libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev libxml2-dev libcurl4-openssl-dev libfontconfig1-dev && \
   R -e "install.packages('tidyverse')"


EXPOSE 8787


ENTRYPOINT ["/entrypoint.sh"]

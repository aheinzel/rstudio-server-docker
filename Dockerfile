FROM ubuntu:22.04


ARG rstudio_server_deb_url


RUN apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get -y install r-base curl gdebi-core locales git


RUN locale-gen "en_US.UTF-8"

ENV LC_ALL=en_US.UTF-8



RUN curl -L "$rstudio_server_deb_url" > /tmp/rstudio-sever.deb && \
   (\
      dpkg -i /tmp/rstudio-sever.deb && \
      rm /tmp/rstudio-sever.deb \
   ) || \
   apt-get update && \
   apt-get -y install --fix-broken && \
   dpkg -i /tmp/rstudio-sever.deb && \
   rm /tmp/rstudio-sever.deb


RUN echo '\
[*]\n\
log-level=info\n\
logger-type=stderr\n\
' > /etc/rstudio/logging.conf


ADD entrypoint.sh /entrypoint.sh


EXPOSE 8787


ENTRYPOINT ["/entrypoint.sh"]

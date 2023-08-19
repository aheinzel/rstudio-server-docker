FROM ubuntu:22.04

RUN apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get -y install r-base curl gdebi-core


RUN curl -L "https://s3.amazonaws.com/rstudio-ide-build/server/jammy/amd64/rstudio-server-2022.07.3-586-amd64.deb" > /tmp/rstudio-sever.deb && \
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

ENTRYPOINT ["/entrypoint.sh"]

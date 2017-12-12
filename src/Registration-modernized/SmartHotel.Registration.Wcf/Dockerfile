FROM microsoft/wcf
ARG source
WORKDIR /inetpub/wwwroot
COPY ${source:-obj/Docker/publish} .

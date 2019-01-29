FROM microsoft/aspnet:4.7.1-windowsservercore-ltsc2016
ARG source
WORKDIR /inetpub/wwwroot
COPY ${source:-obj/Docker/publish} .

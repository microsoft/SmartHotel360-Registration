ARG tag
FROM mcr.microsoft.com/dotnet/framework/wcf:${tag:-4.8}
ARG source
WORKDIR /inetpub/wwwroot
COPY ${source:-obj/Docker/publish} .

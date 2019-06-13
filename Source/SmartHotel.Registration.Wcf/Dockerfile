ARG tag
FROM mcr.microsoft.com/dotnet/framework/wcf:${tag:-4.8}
EXPOSE 80
ARG source
WORKDIR /inetpub/wwwroot
COPY ${source:-obj/Docker/publish} .
#ENTRYPOINT ["powershell"]
#CMD ["c:\\ServiceMonitor", "w3svc"] 
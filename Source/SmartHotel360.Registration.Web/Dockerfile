ARG tag
FROM mcr.microsoft.com/dotnet/framework/aspnet:${tag:-4.8}
ARG source
EXPOSE 80
WORKDIR /inetpub/wwwroot
COPY ${source:-obj/Docker/publish} .
#ENTRYPOINT ["powershell"]  
#CMD ["c:\\ServiceMonitor", "w3svc"]
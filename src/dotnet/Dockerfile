# Build
FROM mcr.microsoft.com/dotnet/core/sdk:2.2.402-alpine3.8 as builder
WORKDIR /src
COPY ./HelloWorld /src
RUN dotnet restore
RUN dotnet publish -r linux-musl-x64 -c Release -o build

# Run
FROM mcr.microsoft.com/dotnet/core/runtime:2.2-alpine3.8
RUN mkdir -p /app
WORKDIR /app
# RUN apk --update upgrade && \
#     apk add nodejs npm
#COPY ./ ./
COPY --from=builder /src/build ./
ENTRYPOINT [ "/usr/bin/dotnet", "HelloWorld.dll" ]
FROM alpine:3.8
RUN mkdir -p /app
WORKDIR /app
RUN apk --update upgrade && \
    apk add nodejs npm
COPY ./ ./
ENTRYPOINT [ "/usr/bin/npm", "start" ]

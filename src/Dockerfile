FROM alpine:3.8
RUN mkdir -p /app
WORKDIR /app
RUN apk --update upgrade && \
    apk add nodejs npm
COPY ./ ./
ENV SGXLKL_VERBOSE=1
ENV SGXLKL_HEAP=2048M
ENV SGXLKL_DISK_SIZE=100M
ENTRYPOINT ["/usr/bin/node", "index.js"]

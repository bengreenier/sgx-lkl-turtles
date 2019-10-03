FROM alpine:3.8
RUN mkdir -p /app
WORKDIR /app
RUN apk --update upgrade && \
    apk add nodejs npm
COPY ./ ./

# Enable SGXLKL verbosity
ENV SGXLKL_VERBOSE=1
# Scale up the SGXLKL heap size
ENV SGXLKL_HEAP=640M
# Size our SGXLKL disk
# Note: This is the only __mandatory__ option
ENV SGXLKL_DISK_SIZE=100M

ENTRYPOINT ["/usr/bin/node", "--max-old-space-size=512", "index.js"]

FROM alpine:3.8
RUN mkdir -p /app
WORKDIR /app
RUN apk --update upgrade && \
    apk add python
COPY ./ ./
ENTRYPOINT [ "/usr/bin/python", "./hello.py" ]
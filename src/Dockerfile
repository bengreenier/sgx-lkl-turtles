# Builder
FROM alpine:3.8 as builder
WORKDIR /src
RUN apk --update upgrade && \
    apk add nodejs npm
RUN npm install -g typescript
COPY ./ /src
RUN npm install
RUN tsc

# Runner
FROM alpine:3.8
RUN mkdir -p /app
WORKDIR /app
RUN apk --update upgrade && \
    apk add nodejs npm
COPY --from=builder /src/build ./
COPY package.json ./
ENTRYPOINT [ "/usr/bin/npm", "start" ]
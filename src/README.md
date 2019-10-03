# src

A hello world [Node](https://nodejs.org) app using [Typescript](http://www.typescriptlang.org/), designed to run inside an [alpine](https://hub.docker.com/_/alpine) container.

## Getting started

Build and run Typescript app inside an alpine 3.8 docker image:

```
cd ./src

docker build -t echoserver/typescript .

docker run -it -p 8080:8080 echoserver/typescript:latest
```


### Inside your host os

This assumes your host has a valid [Node](https://nodejs.org) installation.

Install typescript
```
npm install -g typescript
```

```
cd ./src
tsc
cp package.json ./build
cd ./build && npm start
```

### Inside a container

This assumes you have [Docker](https://hub.docker.com) installed.

```
docker build -t sgx-lkl-turtles-app:dev .

docker run -it -p 8080:8080 --rm --privileged -v //var/run/docker.sock:/var/run/docker.sock sgx-lkl-turtles-app:dev 
```
# src

A hello world [Node](https://nodejs.org) app, designed to run inside an [alpine](https://hub.docker.com/_/alpine) container.

## Getting started

There's no transpile or build steps, just running!

### Inside your host os

This assumes your host has a valid [Node](https://nodejs.org) installation.

```
npm start
```

### Inside a container

This assumes you have [Docker](https://hub.docker.com) installed.

```
docker build -t sgx-lkl-turtles-app:dev .
docker run -it --rm sgx-lkl-turtles-app:dev
```

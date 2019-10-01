# src

A hello world [dotnet core](https://docs.microsoft.com/en-us/dotnet/core/) app, designed to run inside an [alpine](https://hub.docker.com/_/alpine) container.

## Getting started



### Inside your host os

This assumes your host has a valid [dotnet core runtime](https://mcrflowprodcentralus.cdn.mscr.io/mcrprod/dotnet/core/sdk?P1=1569932408&P2=1&P3=1&P4=X%2Boh%2B5TMjUi44a2e50P29yi%2FR%2FjZ0lzOZnTt9aUGnPs%3D&se=2019-10-01T12%3A20%3A08Z&sig=mLrM0P3I0ZPkslTudZ%2F2v9XsEyK%2B4tfUo1w%2BMX1tEQ4%3D&sp=r&sr=b&sv=2015-02-21) installation.

```
dotnet HelloWorld.dll
```

### Inside a container

This assumes you have [Docker](https://hub.docker.com) installed.

```
docker build -t sgx-lkl-turtles-app:dev .
docker run -it --rm sgx-lkl-turtles-app:dev
```

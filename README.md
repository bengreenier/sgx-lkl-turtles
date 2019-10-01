# SGX-LKL-Turtles

> 🚨 This project is an unsupported experiment.

Docker-in-docker [SGX-LKL](https://github.com/lsds/sgx-lkl) sample of a Node [hello world app](./src). 🧙‍📦⚡

![Project Header](./.github/header.png)

I needed a sample to determine how Node apps might run inside SGX-LKL (in an enclave). I also wanted to try out
developing the release entirely inside a docker container. This requires docker-in-docker, to generate the SGX-LKL
image that will run on the enclave.

## Getting started

> Note: This is currently configured to run using simulated mode (not against real enclave hardware). To modify it, specify `--build-arg MAKE_TARGET=""` during docker build.

To run the sample on your own, just grab and run the runtime docker container from this repo's packages:

```
# Gets the container from github
# Runs it in privileged mode
# Forwards port 8080 (so your port 8080)
# Forwards the docker daemon control socket

docker run -it --rm --privileged -p 8080:8080 -v //var/run/docker.sock:/var/run/docker.sock bengreenier/sgx-lkl-turtles:latest-sim
```

You should see:

```
Creating ./app.img from Dockerfile ./src/Dockerfile...
Building Docker image...
Creating and exporting Docker container...
Creating disk image file...
Succesfully created ./app.img.
Cleaning up temporary files...
[    SGX-LKL   ] No tap device specified, networking will not be available.
[    SGX-LKL   ] Kernel command line: ""
[    SGX-LKL   ] Adding entropy to entropy pool.
[    SGX-LKL   ] wg0 has public key KNAL8UQFWViNDi1WtGNx4wqsH9BCQ9Xwv8UX7+Itw3Y=
[    SGX-LKL   ] Set working directory /
[    SGX-LKL   ] Calling application main
Hello world. I'm inside an enclave!
    SGX-LKL   ] Set working directory /
```

When you see this, you can test the echo server. For example:

```
curl -d "echo test" -X POST http://localhost:8080
```

Note that we've limited the [v8 max-old-space-size](https://stackoverflow.com/a/48392705) to `512MB` and adjusted the [SGXLKL_HEAP](https://github.com/lsds/sgx-lkl/blob/master/src/main/sgxlkl_run.c#L232) to `640MB`. This limits the possibilities of this sample app, but helps keep the runtime quite small.

## Building yourself

This is super easy, and depends only on [Docker](https://hub.docker.com).

```
# This will take a while (~25m)
docker build -t sgx-lkl-turtles:dev .
```

### Configuration

You can modify the image during the build phase to target physical hardware, or simulated hardware (the default). 

| Hardware    | MAKE_TARGET       |
| ----------- | ----------------- |
| Physical    | `""`              |
| Simulated   | `"sim DEBUG=true"`|

For example:

```
docker build --build-arg MAKE_TARGET="" -t sgx-lkl-turtles:dev .
```

That's it! 🎉

## Credits

+ This wouldn't be possible without the awesome [SGX-LKL Project](https://github.com/lsds/sgx-lkl).
+ Icons made by [Pixel perfect](https://www.flaticon.com/authors/pixel-perfect) from [www.flaticon.com](https://www.flaticon.com/).

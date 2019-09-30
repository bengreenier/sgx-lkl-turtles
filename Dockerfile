FROM ubuntu:bionic-20190912.1 as core
# Install common os deps
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    sudo \
    git \
    openssl
# Install docker gpg key and apt source
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
# Install docker cli
RUN apt-get update && apt-get install -y docker-ce-cli
# Create tools directories
RUN mkdir -p /tools/src && mkdir -p /tools/bin
WORKDIR /tools/src
# Setup our build vars
ARG MAKE_ENV="DEBUG=true"
ARG MAKE_TARGET="sim"
ENV CORE_MAKE_ENV=${MAKE_ENV}
ENV CORE_MAKE_TARGET=${MAKE_TARGET}

# an intermediate, where we build lkl and copy the tools over
FROM core as with-lkl
RUN sudo apt-get install -y \
  make gcc g++ bc python xutils-dev bison flex libgcrypt20-dev libjson-c-dev \
  automake autopoint autoconf pkgconf libtool libcurl4-openssl-dev \
  libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler \
  libssl-dev wget rsync
# clone our source, and build it
RUN git clone --recursive https://github.com/lsds/sgx-lkl.git
WORKDIR /tools/src/sgx-lkl
RUN make $CORE_MAKE_TARGET $CORE_MAKE_ENV
RUN make install PREFIX="/tools" \
  && cp /tools/src/sgx-lkl/tools/gen_enclave_key.sh /tools/bin \
  && cp /tools/src/sgx-lkl/build/libsgxlkl.so /tools/bin

# must be run with: --privileged -v //var/run/docker.sock:/var/run/docker.sock -it <image_name>
FROM core as app-platform
RUN apt-get update && apt-get install -y \
    bc libjson-c-dev libprotobuf-c-dev openssl dos2unix

RUN mkdir -p /app/src
WORKDIR /app/src
COPY --from=with-lkl /tools/bin/ /tools/bin/
# TODO(bengreenier): Do this with volume mount
COPY ./src ./

WORKDIR /app
COPY ./entrypoint.sh ./
RUN dos2unix ./entrypoint.sh && chmod +x ./entrypoint.sh

ENTRYPOINT ./entrypoint.sh \
  "$CORE_MAKE_TARGET" \
  ./app.key \
  /tools/bin/libsgxlkl.so \
  ./src/Dockerfile \
  ./app.img \
  /app/index.js

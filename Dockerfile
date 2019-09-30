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

# Enforce that the entrypoint be bash (and default to running "docker version")
ENTRYPOINT [ "/bin/bash" ]
CMD ["-c", "docker version"]

FROM core as with-lkl
WORKDIR /tools/src
RUN git clone --recursive https://github.com/lsds/sgx-lkl.git
WORKDIR /tools/src/sgx-lkl
RUN sudo apt-get install -y \
  make gcc g++ bc python xutils-dev bison flex libgcrypt20-dev libjson-c-dev \
  automake autopoint autoconf pkgconf libtool libcurl4-openssl-dev \
  libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler \
  libssl-dev wget rsync
ARG MAKE_TARGET="sim DEBUG=true"
RUN make ${MAKE_TARGET}
RUN cp build/sgx-lkl-run /tools/bin \
  && cp build/libsgxlkl.so /tools/bin \
  && cp tools/sgx-lkl-disk /tools/bin

WORKDIR /
ENTRYPOINT [ "/bin/bash" ]

# must be run with: --privileged -v //var/run/docker.sock:/var/run/docker.sock -it <image_name>
FROM core as app-platform
RUN apt-get update && apt-get install -y \
    bc libjson-c-dev libprotobuf-c-dev
RUN mkdir -p /app/src
WORKDIR /app/src
COPY --from=with-lkl /tools/bin/ /tools/bin/
# TODO(bengreenier): Do this with volume mount
COPY ./src ./
WORKDIR /app
# TODO(bengreenier): Figure out a good path to cd /app && npm start
#
# we have to disk-create at runtime, as we can't have docker at build time
RUN echo "/tools/bin/sgx-lkl-disk create --size=100M --docker=./src/Dockerfile ./app.img && \
  SGXLKL_VERBOSE=1 SGXLKL_HEAP=640M /tools/bin/sgx-lkl-run ./app.img /usr/bin/node --max-old-space-size=512 /app/index.js" > start.sh 
RUN chmod +x start.sh
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/app/start.sh" ]

#!/bin/bash

#
# The target that was fed to make during the build
# We use this to make some boot up decisions
#
MAKE_TARGET=$1
#
# The path where we'll write our signing key, if needed
#
SIGN_KEY_PATH=$2
#
# The path to the binary that we'll sign (libsgxlkl.so)
#
SIGN_KEY_BIN_PATH=$3
#
# The path to the Dockerfile we'll build the image to
#
DOCKER_PATH=$4
#
# The path where we'll write our docker image
#
DOCKER_IMG_PATH=$5
#
# The node entrypoint inside the docker image at which we'll start execution
# TODO(bengreenier): refactor this to a npm start call in the app directory 
#
DOCKER_ENTRY_PATH=$6

echo "MAKE_TARGET: $MAKE_TARGET"
echo "SIGN_KEY_PATH: $SIGN_KEY_PATH"
echo "SIGN_KEY_BIN_PATH: $SIGN_KEY_BIN_PATH"
echo "DOCKER_PATH: $DOCKER_PATH"
echo "DOCKER_IMG_PATH: $DOCKER_IMG_PATH"
echo "DOCKER_ENTRY_PATH: $DOCKER_ENTRY_PATH"

# Generate a unique, per-runtime key with which our enclave will be signed
/tools/bin/gen_enclave_key.sh $SIGN_KEY_PATH

# If we are running in hardware mode, we need to sign the enclave library
if [ "$MAKE_TARGET" != "sim" ]; then
    echo "Entrypoint: Signing..."
    # Sign it, with the above key
    /tools/bin/sgx-lkl-sign -k $SIGN_KEY_PATH -f $SIGN_KEY_BIN_PATH
    echo "Entrypoint: Signed."
fi

# Create our actual disk (that we'll mount in the enclave)
/tools/bin/sgx-lkl-disk create --size=100M --docker=$DOCKER_PATH $DOCKER_IMG_PATH

# Configure our LKL environment
export SGXLKL_VERBOSE=1
export SGXLKL_HEAP=640M
export SGXLKL_KEY=$SIGN_KEY_PATH

# Run lkl
echo "Entrypoint: Running..."
/tools/bin/sgx-lkl-run $DOCKER_IMG_PATH /usr/bin/node --max-old-space-size=512 $DOCKER_ENTRY_PATH
echo "Entrypoint: Ran."
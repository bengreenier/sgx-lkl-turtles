#!/bin/bash

# exit when any command fails
set -e

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

echo "MAKE_TARGET: $MAKE_TARGET"
echo "SIGN_KEY_PATH: $SIGN_KEY_PATH"
echo "SIGN_KEY_BIN_PATH: $SIGN_KEY_BIN_PATH"
echo "DOCKER_PATH: $DOCKER_PATH"
echo "DOCKER_IMG_PATH: $DOCKER_IMG_PATH"
echo "DOCKER_ENTRY_PATH: $DOCKER_ENTRY_PATH"

# Generate a unique, per-runtime key with which our enclave will be signed
/tools/bin/gen_enclave_key.sh "$SIGN_KEY_PATH"

# If we are running in hardware mode, we need to sign the enclave library
if [[ "$MAKE_TARGET" != "sim" ]]; then
    echo "Entrypoint: Signing..."
    # Sign it, with the above key
    /tools/bin/sgx-lkl-sign -k $SIGN_KEY_PATH -f $SIGN_KEY_BIN_PATH
    echo "Entrypoint: Signed."
fi

# Create our actual disk (that we'll mount in the enclave)
# Note: as we want to extract info (like entrypoint) from the dockerfile, we give sgx-lkl-disk an existing image, not just the dockerfile
TMP_DOCKER_IMG_ID=$(cat /proc/sys/kernel/random/uuid)
docker build -t $TMP_DOCKER_IMG_ID -f $DOCKER_PATH $(dirname $DOCKER_PATH)

# Parsing out some critical env vars demands its own section
# We must determine the image size and remove PATH (we don't allow overriding the host app path)
DOCKER_IMG_ENV=$(docker image inspect -f "{{range \$conf := .Config.Env}}{{(\$conf)}} {{end}}" $TMP_DOCKER_IMG_ID)

SGXLKL_DISK_SIZE_CONST="SGXLKL_DISK_SIZE"

# If we don't have an image size, we cannot proceed
if [[ "$DOCKER_IMG_ENV" != *"$SGXLKL_DISK_SIZE_CONST"* ]]; then
    echo "Docker image does not set '$SGXLKL_DISK_SIZE_CONST'. Please define the LKL disk size using ENV $SGXLK_DISK_SIZE_CONST in '$DOCKER_PATH'."
    # If we're going to exit early, we need to clean up
    docker image rm $TMP_DOCKER_IMG_ID
    exit -1
fi

# Parse out our special env values
DOCKER_IMG_ENV_DISK_SIZE=$(echo "$DOCKER_IMG_ENV" | tr ' ' '\n' | grep "$SGXLKL_DISK_SIZE_CONST" | tr '=' '\n' | sed -n 2p)
DOCKER_IMG_ENV_PATH=$(echo "$DOCKER_IMG_ENV" | tr ' ' '\n' | grep PATH | tr '=' '\n' | sed -n 2p)
DOCKER_IMG_ENV=$(echo "$DOCKER_IMG_ENV" | tr ' ' '\n' | grep -v "PATH=$DOCKER_IMG_ENV_PATH" | tr '\n' ' ')

# Parse our other metadata
DOCKER_IMG_ENTRY=$(docker image inspect -f "{{range \$conf := .Config.Entrypoint}}{{(\$conf)}} {{end}}" $TMP_DOCKER_IMG_ID)
DOCKER_IMG_WORKDIR=$(docker image inspect -f "{{.Config.WorkingDir}}" $TMP_DOCKER_IMG_ID)

# Generate the image, and cleanup (we're done with docker work now)
/tools/bin/sgx-lkl-disk create --size=$DOCKER_IMG_ENV_DISK_SIZE --docker=$TMP_DOCKER_IMG_ID $DOCKER_IMG_PATH
docker image rm $TMP_DOCKER_IMG_ID

echo "Entrypoint: Docker disk size: $DOCKER_IMG_ENV_DISK_SIZE"
echo "Entrypoint: Docker environment: $DOCKER_IMG_ENV"
echo "Entrypoint: Docker working directory: $DOCKER_IMG_WORKDIR"
echo "Entrypoint: Docker entrypoint: $DOCKER_IMG_ENTRY"

# Inflate the docker environment into our environment
# Note: however, we don't allow the docker environment to override some things
# Namely: PATH, SGXLKL_CWD, SGXLKL_KEY
export $DOCKER_IMG_ENV
export PATH=$OUR_PATH
export SGXLKL_CWD=$DOCKER_IMG_WORKDIR
export SGXLKL_KEY=$SIGN_KEY_PATH

# Run lkl
echo "Entrypoint: Running..."
/tools/bin/sgx-lkl-run $DOCKER_IMG_PATH $DOCKER_IMG_ENTRY
echo "Entrypoint: Ran."

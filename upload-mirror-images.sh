#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

MAX_NUMBER_OF_TRIES=10

OCP_MIRROR_REGISTRY_REPOSITORY=${1}
OCP_VERSION=${2}
OCP_PULL_SECRET=${3}

number_of_tries=0
until [ "${number_of_tries}" -ge ${MAX_NUMBER_OF_TRIES} ]
do
    echo "[${number_of_tries}/${MAX_NUMBER_OF_TRIES}] Trying to mirror registry..."
    if oc adm release mirror \
        --registry-config=${OCP_PULL_SECRET} \
        --from=quay.io/openshift-release-dev/ocp-release:${OCP_VERSION} \
        --to=${OCP_MIRROR_REGISTRY_REPOSITORY} \
        --to-release-image=${OCP_MIRROR_REGISTRY_REPOSITORY}:${OCP_VERSION} \
        --insecure=true
    then
        break
    else
        number_of_tries=$((number_of_tries+1))
        sleep 5
    fi
done

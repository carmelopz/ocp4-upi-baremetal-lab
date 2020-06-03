#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

MAX_NUMBER_OF_TRIES=10

OCP_MIRROR_REGISTRY=${1}
OCP_VERSION=${2}
OCP_PULL_SECRET=${3}

number_of_tries=0
until [ "${number_of_tries}" -ge ${MAX_NUMBER_OF_TRIES} ]
do
    echo "[${number_of_tries}/${MAX_NUMBER_OF_TRIES}] Trying to mirror catalog..."
    if oc adm catalog build \
        --appregistry-org redhat-operators \
        --registry-config=${OCP_PULL_SECRET} \
        --from=registry.redhat.io/openshift4/ose-operator-registry:${OCP_VERSION} \
        --to=${OCP_MIRROR_REGISTRY} \
        --insecure=true
    then
        break
    else
        number_of_tries=$((number_of_tries+1))
        sleep 5
    fi
done

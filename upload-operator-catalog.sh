#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

MAX_NUMBER_OF_TRIES=10

OCP_MIRROR_REGISTRY=${1}
OCP_VERSION=${2}
OCP_RELEASE=$(echo ${OCP_VERSION} | head -c 3)
OCP_PULL_SECRET=${3}

number_of_tries=0
until [ "${number_of_tries}" -ge ${MAX_NUMBER_OF_TRIES} ]
do
    echo "[${number_of_tries}/${MAX_NUMBER_OF_TRIES}] Trying to mirror catalog..."
    if oc adm catalog build \
        --appregistry-org redhat-operators \
        --registry-config=${OCP_PULL_SECRET} \
        --from=registry.redhat.io/openshift4/ose-operator-registry:v${OCP_RELEASE} \
        --to=${OCP_MIRROR_REGISTRY}/olm/redhat-operators:v1 \
        --filter-by-os="linux/amd64" \
        --insecure=true
    then
        # Mirror catalog to disconnected registry
        oc adm catalog mirror \
            ${OCP_MIRROR_REGISTRY}/olm/redhat-operators:v1 \
            ${OCP_MIRROR_REGISTRY} \
            --registry-config=${OCP_PULL_SECRET} \
            --filter-by-os="linux/amd64" \
            --insecure=true

        # Disable default sources
        oc patch OperatorHub cluster --type json \
            -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
        
        # Create discconnected source
        oc apply -f src/olm

        # Add mirror configuration for catalog repository
        oc apply -f redhat-operators-manifests
        break
    else
        number_of_tries=$((number_of_tries+1))
        sleep 5
    fi
done

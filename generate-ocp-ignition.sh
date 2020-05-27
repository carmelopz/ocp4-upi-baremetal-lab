#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

installation_dir="src/ignition/openshift/${OCP_ENVIRONMENT}"

# Generate ignition files
if [ ! -f "${installation_dir}/master.ign" ]; then
    ./openshift-install create manifests --dir=${installation_dir} --log-level=debug
    # yq write -i ${installation_dir}/manifests/cluster-scheduler-02-config.yml \
    #     'spec.mastersSchedulable' 'false'
    #./openshift-install create ignition-configs --dir=${installation_dir} --log-level=debug
fi
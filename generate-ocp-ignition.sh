#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

installation_dir="src/ignition/openshift/${OCP_ENVIRONMENT}"

# Generate ignition files
if [ ! -f "${installation_dir}/master.ign" ]; then

    # Backup install-config.yaml file as it is removed during installation
    cp ${installation_dir}/install-config.yaml ${installation_dir}/install-config.yaml.bkp

    # Generate manifests from install-config.yaml file
    ./openshift-install create manifests --dir=${installation_dir} --log-level=debug

    # Do not make masters schedulables
    # yq write -i ${installation_dir}/manifests/cluster-scheduler-02-config.yml \
    #     'spec.mastersSchedulable' 'false'

    # Generate ignitions files from manifests
    ./openshift-install create ignition-configs --dir=${installation_dir} --log-level=debug

    # Recover install-config.yaml file
    mv ${installation_dir}/install-config.yaml.bkp ${installation_dir}/install-config.yaml
fi
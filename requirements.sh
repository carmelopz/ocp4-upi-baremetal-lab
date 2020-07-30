#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Global variables
TF_VERSION="0.12.28"
TF_PROVIDERS_DIR="${HOME}/.terraform.d/plugins"
TF_LIBVIRT_PROVIDER_VERSION="v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz"
OC_VERSION="4.5"
FCCT_VERSION="0.6.0"

# install_terraform <installation_dir> <terraform_version>
function install_terraform {
    tf_installation_dir=${1}
    tf_binary="${tf_installation_dir}/terraform"
    tf_version=${2}

    # Create installation dir
    mkdir -p ${tf_installation_dir}

    # Download Terraform from Hashicorp site
    curl -s -L --output ${tf_binary}.zip \
        https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip

    # Install Terraform
    unzip -d ${tf_installation_dir} ${tf_binary}.zip
    chmod +x ${tf_binary}
    rm -f ${tf_binary}.zip
}

# install_tf_provider <installation_dir> <provider_name> <provider_source>
function install_tf_provider {
    provider_install_dir=${1}
    provider_name=${2}
    provider_binary="${provider_install_dir}/${provider_name}"
    provider_src=${3}

    # Create plugins dir
    mkdir -p ${provider_install_dir}

    # Download provider from source
    curl -s -L --output ${provider_binary}.tar.gz ${provider_src}

    # Install Provider
    tar -xvf ${provider_binary}.tar.gz -C ${provider_install_dir}
    chmod +x ${provider_binary}
    rm -f ${provider_binary}.tar.gz
}

# install_oc <installation_dir> <oc_version>
function install_oc {

    oc_install_dir=${1}
    oc_binary="${oc_install_dir}/oc"
    oc_version=${2}

    # Download oc
    curl -L --output ${oc_binary}.tar.gz \
        https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${OC_VERSION}/openshift-client-linux.tar.gz

    # Install oc
    tar -xvf ${oc_binary}.tar.gz -C ${oc_install_dir} oc
    chmod +x ${oc_binary}
    rm -f ${oc_binary}.tar.gz
}

# install_fcct <installation_dir> <fcct_version>
function install_fcct {

    fcct_installation_dir=${1}
    fcct_binary="${fcct_installation_dir}/fcct"
    fcct_version=${2}

    # Download and install fcct
    curl -s -L --output ${fcct_binary} \
        https://github.com/coreos/fcct/releases/download/v${fcct_version}/fcct-x86_64-unknown-linux-gnu
    chmod +x ${fcct_binary}
}

# Install libvirt
if ! (which virsh &> /dev/null); then
    echo "Follow the instructions to install libvirt in your linux distribution."
else
    echo "Libvirt is already installed."
fi

# Install terraform
if ! (which terraform &> /dev/null); then
    echo "Installing Terraform ${TF_VERSION}..."
    install_terraform ${HOME}/bin ${TF_VERSION}
    echo "Successfully installed!"
else
    terraform_current_version=$(terraform version)
    echo "${terraform_current_version} is already installed."
fi

# Install libvirt provider plugin
if ! (ls ${TF_PROVIDERS_DIR}/terraform-provider-libvirt &> /dev/null); then
    echo "Installing libvirt provider for Terraform..."
    install_tf_provider ${TF_PROVIDERS_DIR} terraform-provider-libvirt \
        "https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/${TF_LIBVIRT_PROVIDER_VERSION}"
    echo "Successfully installed!"
else
    libvirt_tf_current_version=$(echo "$(${TF_PROVIDERS_DIR}/terraform-provider-libvirt -version)" |\
        head -n 1 | rev | cut -d " " -f 1 | rev)
    echo "Libvirt provider ${libvirt_tf_current_version} for Terraform is already installed."
fi

# Install Openshift client
if ! (which oc &> /dev/null); then
    echo "Installing OC ${OC_VERSION}..."
    install_oc ${HOME}/bin ${OC_VERSION}
    echo "Successfully installed!"
else
    oc_current_version=$(oc version --client)
    echo "${oc_current_version} is already installed."
fi

# Install Fedora CoreOS Config Transpiler
if ! (which fcct &> /dev/null); then
    echo "Installing FCCT ${FCCT_VERSION}..."
    install_fcct ${HOME}/bin ${FCCT_VERSION}
    echo "Successfully installed!"
else
    fcct_current_version=$(fcct --version)
    echo "${fcct_current_version} is already installed."
fi

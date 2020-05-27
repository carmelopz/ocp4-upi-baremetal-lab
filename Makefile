# Terraform parameters
ocp_version="4.3.21"
environment=localhost
tf_cmd=terraform
tf_files=src
tf_backend_conf=configuration/backend
tf_variables=configuration/tfvars
libvirt_pool_dir=/var/lib/libvirt/storage
libvirt_imgs_dir=/var/lib/libvirt/images

all: init plan deploy test
requirements:
	@echo "Installing dependencies..."
	@./requirements.sh
init:
	@echo "Elevating privileges..." && sudo -v

	@echo "Initializing Terraform plugins"
	terraform init \
		-backend-config="$(tf_backend_conf)/$(environment).conf" $(tf_files)

	@echo "Configuring dnsmasq..."
	@sudo chmod 777 /etc/NetworkManager/conf.d
	@sudo chmod 777 /etc/NetworkManager/dnsmasq.d

	@echo "Configuring path $(libvirt_pool_dir) for libvirt pool storage..."
	@sudo install \
		--owner="root" \
		--group="root" \
		--mode="0750" \
   		--context="system_u:object_r:virt_image_t:s0" \
    	--directory $(libvirt_pool_dir)

	@echo "Creating directory $(libvirt_imgs_dir) for libvirt images..."
	@sudo install \
		--owner="root" \
		--group="libvirt" \
		--mode="0770" \
   		--context="system_u:object_r:virt_image_t:s0" \
    	--directory $(libvirt_imgs_dir)

ifeq (,$(wildcard openshift-install))
	@echo "Downloading Openshift installer"
	@wget -O openshift-install-linux.tar.gz \
		https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$(ocp_version)/openshift-install-linux.tar.gz
	@tar -xvf openshift-install-linux.tar.gz openshift-install
	@rm -f openshift-install-linux.tar.gz
endif

	@echo "Rendering FCC configuration for helper node..."
	@podman run -i --rm quay.io/coreos/fcct:release --pretty --strict \
  		< src/ignition/helper-node/ignition.yml > src/ignition/helper-node/ignition.json.tpl

plan:
	@echo "Planing infrastructure changes..."
	terraform plan \
		-var-file="$(tf_variables)/default.tfvars" \
		-var-file="$(tf_variables)/$(environment).tfvars" \
		-out "output/tf.$(environment).plan" \
		$(tf_files)
deploy:
	@echo "Deploying infrastructure..."
	terraform apply output/tf.$(environment).plan
test:
	@echo "Testing infrastructure..."
destroy: plan
	@echo "Elevating privileges..." && sudo -v

	@echo "Destroying infrastructure..."
	terraform destroy \
		-auto-approve \
		-var-file="$(tf_variables)/default.tfvars" \
		-var-file="$(tf_variables)/$(environment).tfvars" \
		$(tf_files)
	@rm -rf .terraform
	@rm -rf output/tf.$(environment).plan
	@rm -rf state/terraform.$(environment).tfstate

	@echo "Deleting Openshift installation files..."
	@rm -f openshift-install
	@rm -rf src/ignition/openshift/$(environment)

	@echo "Restoring network configuration..."
	@sudo chmod 755 /etc/NetworkManager/conf.d
	@sudo chmod 755 /etc/NetworkManager/dnsmasq.d
	@sudo systemctl restart NetworkManager
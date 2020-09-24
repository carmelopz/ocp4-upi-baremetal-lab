locals {
  olm = {
    path       = format("day-two/olm/%s", var.OCP_ENVIRONMENT)
    repository = "olm/redhat-operators"
    version    = format("%s-v1", local.ocp_installer.release)
    arch       = "linux/amd64"
  }
}

resource "local_file" "olm_catalog_source" {
  filename             = format("%s/catalog-source.yml", local.olm.path)
  file_permission      = "0644"
  directory_permission = "0755"
  content              = <<-EOF
    apiVersion: operators.coreos.com/v1alpha1
    kind: CatalogSource
    metadata:
      name: redhat-operators-disconnected
      namespace: openshift-marketplace
    spec:
      displayName: Red Hat Operators (Disconnected)
      image: ${local.registry.address}/${local.olm.repository}:v${local.olm.version}
      sourceType: grpc
      publisher: Manual
  EOF
}

resource "local_file" "olm_mirror_catalog_image" {
  filename             = format("%s/mirror-catalog-image.sh", local.olm.path)
  file_permission      = "0744"
  directory_permission = "0755"
  content              = <<-EOF
    #!/usr/bin/env bash

    # Disable default sources
    oc patch OperatorHub cluster --type json \
        -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

    # Get catalog images
    oc image info \
      registry.redhat.io/openshift4/ose-operator-registry:v${local.ocp_installer.release} \
        --registry-config=${local_file.ocp_pull_secret.filename} \
        --filter-by-os=${local.olm.arch}

    # Build catalog images
    oc adm catalog build \
      --appregistry-org=redhat-operators \
      --registry-config=${local_file.ocp_pull_secret.filename} \
      --from=registry.redhat.io/openshift4/ose-operator-registry:v${local.ocp_installer.release} \
      --to=${local.registry.address}/${local.olm.repository}:v${local.olm.version} \
      --filter-by-os=${local.olm.arch} \
      --insecure=true

    # Download catalog database
    mkdir -p ${local.olm.path}/database

    oc adm catalog mirror \
      ${local.registry.address}/${local.olm.repository}:v${local.olm.version} ${local.registry.address} \
      --manifests-only \
      --to-manifests=${local.olm.path}/manifests \
      --path="/:${local.olm.path}/database" \
      --registry-config=${local_file.ocp_pull_secret.filename} \
      --filter-by-os=".*" \
      --insecure=true

    # Get operator catalog
    sqlite3 ${local.olm.path}/database/bundles.db \
      "select operatorbundle_name from related_image group by operatorbundle_name;" \
        > ${local.olm.path}/manifests/catalog.txt

    # Install operators from catalog
    OPERATORS=(%{ for operator in var.ocp_cluster.operators } "${operator}" %{ endfor })

    rm -f ${local.olm.path}/manifests/mapping-filtered.txt

    for OPERATOR in "$${OPERATORS[@]}"; do
      OPERATOR_IMAGES=(`sqlite3 ${local.olm.path}/database/bundles.db \
        "select image from related_image where operatorbundle_name like '$${OPERATOR}%';"`)

      for OPERATOR_IMAGE in "$${OPERATOR_IMAGES[@]}"; do
        grep $${OPERATOR_IMAGE} ${local.olm.path}/manifests/mapping.txt \
          >> ${local.olm.path}/manifests/mapping-filtered.txt
      done
    done

    # Mirror filtered operators
    oc image mirror \
      --filename=${local.olm.path}/manifests/mapping-filtered.txt \
      --registry-config=${local_file.ocp_pull_secret.filename} \
      --filter-by-os=".*" \
      --insecure=true

    # Create disconnected source
    oc apply -f ${local.olm.path}/catalog-source.yml

    # Apply mirror configuration
    oc apply -f ${local.olm.path}/manifests/imageContentSourcePolicy.yaml
  EOF
}

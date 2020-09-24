#!/usr/bin/env bash

# Disable default sources
oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# Get catalog images
oc image info \
  registry.redhat.io/openshift4/ose-operator-registry:v4.4 \
    --registry-config=output/openshift-install/localhost/pull-secret.json \
    --filter-by-os=linux/amd64

# Build catalog images
oc adm catalog build \
  --appregistry-org=redhat-operators \
  --registry-config=output/openshift-install/localhost/pull-secret.json \
  --from=registry.redhat.io/openshift4/ose-operator-registry:v4.4 \
  --to=registry.ocp.bmlab.int:5000/olm/redhat-operators:v4.4-v1 \
  --filter-by-os=linux/amd64 \
  --insecure=true

# Download catalog database
mkdir -p day-two/olm/localhost/database

oc adm catalog mirror \
  registry.ocp.bmlab.int:5000/olm/redhat-operators:v4.4-v1 registry.ocp.bmlab.int:5000 \
  --manifests-only \
  --to-manifests=day-two/olm/localhost/manifests \
  --path="/:day-two/olm/localhost/database" \
  --registry-config=output/openshift-install/localhost/pull-secret.json \
  --filter-by-os=".*" \
  --insecure=true

# Get operator catalog
sqlite3 day-two/olm/localhost/database/bundles.db \
  "select operatorbundle_name from related_image group by operatorbundle_name;" \
    > day-two/olm/localhost/manifests/catalog.txt

# Install operators from catalog
OPERATORS=( "red-hat-quay" )

rm -f day-two/olm/localhost/manifests/mapping-filtered.txt

for OPERATOR in "${OPERATORS[@]}"; do
  OPERATOR_IMAGES=(`sqlite3 day-two/olm/localhost/database/bundles.db \
    "select image from related_image where operatorbundle_name like '${OPERATOR}%';"`)

  for OPERATOR_IMAGE in "${OPERATOR_IMAGES[@]}"; do
    grep ${OPERATOR_IMAGE} day-two/olm/localhost/manifests/mapping.txt \
      >> day-two/olm/localhost/manifests/mapping-filtered.txt
  done
done

# Mirror filtered operators
oc image mirror \
  --filename=day-two/olm/localhost/manifests/mapping-filtered.txt \
  --registry-config=output/openshift-install/localhost/pull-secret.json \
  --filter-by-os=".*" \
  --insecure=true

# Create disconnected source
oc apply -f day-two/olm/localhost/catalog-source.yml

# Apply mirror configuration
oc apply -f day-two/olm/localhost/manifests/imageContentSourcePolicy.yaml

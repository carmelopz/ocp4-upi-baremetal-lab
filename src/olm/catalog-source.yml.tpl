apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: operators-catalog
  namespace: openshift-marketplace
spec:
  displayName: Disconnected
  image: ${ocp_registry_mirror}/olm/redhat-operators:v1 
  sourceType: grpc
  publisher: grpc

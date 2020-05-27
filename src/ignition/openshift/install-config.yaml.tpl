apiVersion: v1
metadata:
  name: ${ocp_cluster_name}
baseDomain: ${ocp_dns_domain}
controlPlane:
  name: master
  hyperthreading: Enabled
  replicas: 3
compute:
  - name: worker
    hyperthreading: Enabled
    replicas: 0
platform:
  none: {}
networking:
  networkType: OpenShiftSDN
  machineCIDR: ${ocp_nodes_cidr}
  clusterNetwork:
    - cidr: ${ocp_pods_cidr}
      hostPrefix: ${ocp_pods_range}
  serviceNetwork:
    - ${ocp_svcs_cidr}
pullSecret: '${ocp_pull_secret}'
sshKey: '${ocp_ssh_pubkey}'
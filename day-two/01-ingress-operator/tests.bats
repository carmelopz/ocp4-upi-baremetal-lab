#!/usr/bin/env bats

setup() {
  console_hostname="$(oc whoami --show-console | sed 's/https\?:\/\///')"
}

@test "Verify all replicas are running" {
  expected_output="$(oc get ingresscontroller ${ingress_controller} -o jsonpath='{.spec.replicas}' -n openshift-ingress-operator)"

  run /bin/bash -c "oc get deploy router-${ingress_controller} -o jsonpath='{.status.updatedReplicas}' -n openshift-ingress"

  echo -e "Expected output: $expected_output \nGot: $output"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${expected_output}" ]
}

@test "Verify if ingress with IP ${ingress_ip} is publishing routes" {
  expected_output='{"status":"ok"}'

  run /bin/bash -c "curl -sS --resolve ${console_hostname}:443:${ingress_ip} https://${console_hostname}/health"

  echo -e "Expected output: $expected_output \nGot: $output"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${expected_output}" ]
}


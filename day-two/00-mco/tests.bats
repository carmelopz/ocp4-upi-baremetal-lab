#!/usr/bin/env bats

@test "Verify chrony configuration in ${node} node" {
  expected_output="$(cat mc/chrony.conf)"

  run /bin/bash -c 'oc debug node/'${node}' -- cat /host/etc/chrony.conf 2> /dev/null'

  echo -e "Expected output: $expected_output \nGot: $output"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${expected_output}" ]
}


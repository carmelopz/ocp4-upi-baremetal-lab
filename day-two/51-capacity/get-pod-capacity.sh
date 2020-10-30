#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

POD_REQUEST_CPU="100" # milicores
POD_REQUEST_MEM="100" # Mebibytes

min_number() {
  echo $(( $1 < $2 ? $1 : $2 ))
}

for node in $(oc get nodes -o=custom-columns=NAME:.metadata.name --no-headers); do
  echo "NODE: $node"
  # Get available CPU
  allocated_cpu=$(oc describe node $node | grep 'Allocatable:' -A5 | grep -w "cpu" | awk '{print $2}' | sed 's/m//g')
  request_cpu=$(oc describe node $node | grep 'Allocated' -A6 | grep -w "cpu" | awk '{print $2}' | sed 's/m//g')
  available_cpu=$(( $allocated_cpu - $request_cpu ))
  num_of_pods_by_cpu=$(( $available_cpu / $POD_REQUEST_CPU ))

  # Get available memory
  allocated_mem=$(( $(oc describe node $node | grep 'Allocatable:' -A5 | grep -w "memory" | awk '{print $2}' | sed 's/Ki//g') / 1024 ))
  request_mem=$(oc describe node $node | grep 'Allocated' -A6 | grep -w "memory" | awk '{print $2}' | sed 's/Mi//g')
  available_mem=$(( $allocated_mem - $request_mem ))
  num_of_pods_by_mem=$(( $available_mem / $POD_REQUEST_MEM ))

  echo "  CPU available: $available_cpu""m"
  echo "  Mem available: $available_mem""Mi"
  echo "  Number of pods by CPU: $num_of_pods_by_cpu"
  echo "  Number of pods by mem: $num_of_pods_by_mem"
  echo "  Max number of pods: $(min_number $num_of_pods_by_cpu $num_of_pods_by_mem)"
done

#!/bin/bash
set -e

CLUSTER_NAME="k8s-proxy-lab"

if [ -d "./bin" ]; then
    export PATH=$PWD/bin:$PATH
fi

if ! command -v kind &> /dev/null; then
    echo "Error: 'kind' binary not found. Cannot delete cluster."
    exit 1
fi

if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Deleting Kind cluster: $CLUSTER_NAME..."
    kind delete cluster --name "$CLUSTER_NAME"
    echo "Cluster successfully deleted."
else
    echo "Cluster $CLUSTER_NAME does not exist."
fi

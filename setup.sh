#!/bin/bash
set -e

# Configuration
CLUSTER_NAME="k8s-proxy-lab"
KIND_VERSION="v0.20.0" # Adjust as needed
KUBECTL_VERSION="v1.27.3"
ARCH="amd64" # Change to arm64 if on Apple Silicon

# 1. Download Dependencies (Self-contained)
mkdir -p bin

if [ ! -f bin/kind ]; then
    echo "Downloading Kind..."
    curl -Lo ./bin/kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}
    chmod +x ./bin/kind
fi

if [ ! -f bin/kubectl ]; then
    echo "Downloading Kubectl..."
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
    chmod +x kubectl
    mv kubectl bin/
fi

export PATH=$PWD/bin:$PATH

# 2. Create Cluster
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Creating Kind cluster..."
    kind create cluster --name "$CLUSTER_NAME"
else
    echo "Cluster $CLUSTER_NAME already exists."
fi

echo "Setup complete. kubectl context is set to kind-$CLUSTER_NAME"

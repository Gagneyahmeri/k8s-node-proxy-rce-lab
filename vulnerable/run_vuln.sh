#!/bin/bash
set -e

# Use binaries from the bin folder that was created earlier
export PATH=$PWD/../bin:$PATH

echo "=== Starting Vulnerable Lab Setup ==="

# 2. Deploying rbacs
if [ -f "manifests/rbac.yaml" ]; then
    echo "Deploying RBAC configurations..."
    kubectl apply -f manifests/rbac.yaml
else
    echo "Error: manifests/rbac.yaml not found!"
    exit 1
fi

# 3. Deploy pod
if [ -f "manifests/pod.yaml" ]; then
    echo "Deploying Victim Pod..."
    kubectl apply -f manifests/pod.yaml
else
    echo "Error: manifests/pod.yaml not found!"
    exit 1
fi

# 4. Wait for the Pod to be Ready
echo "Waiting for pod 'victim' to be ready..."
kubectl wait --for=condition=ready pod/victim --timeout=60s

echo "=== Vulnerable Environment Ready ==="
echo "The victim pod is running."
echo "The ServiceAccount 'vuln-test-sa' is configured with 'nodes/proxy' access."

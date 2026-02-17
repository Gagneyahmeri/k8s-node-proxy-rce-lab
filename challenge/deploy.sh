#!/bin/bash
set -e
export PATH=$PWD/../bin:$PWD/bin:$PATH

echo "[*] Deploying CTF Challenge..."

kubectl apply -f manifests/target.yaml
kubectl apply -f manifests/rbac.yaml

echo "[*] Waiting for victim-db..."
kubectl wait --for=condition=ready pod/victim-db --timeout=60s

TOKEN=$(kubectl create token monitor-dev --duration=24h)
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_DATA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

cat <<EOF > player.kubeconfig
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CA_DATA
    server: $SERVER
  name: ctf-cluster
users:
- name: monitor-dev
  user:
    token: $TOKEN
contexts:
- context:
    cluster: ctf-cluster
    user: monitor-dev
  name: ctf-context
current-context: ctf-context
EOF

echo "--------------------------------------------------"
echo "CHALLENGE DEPLOYED!"
echo "The file 'player.kubeconfig' has been created in the root folder."
echo "Hand this file to the player."
echo "--------------------------------------------------"

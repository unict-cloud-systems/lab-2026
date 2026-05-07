#!/usr/bin/env bash
# Install Metrics Server and patch for Multipass (kubelet insecure TLS)
set -euo pipefail

echo "==> Deploying Metrics Server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "==> Patching for kubelet-insecure-tls (required on Multipass)..."
kubectl patch deployment metrics-server \
  -n kube-system \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo "==> Waiting for Metrics Server to be ready..."
kubectl rollout status deployment/metrics-server -n kube-system --timeout=120s

echo ""
echo "==> Done. Test with:"
echo "    kubectl top nodes"
echo "    kubectl top pods -A"
